package org.shypl.sna.impl {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.IllegalStateException;
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.logging.Logger;
	import org.shypl.common.util.CollectionUtils;
	import org.shypl.common.util.NumberUtils;
	import org.shypl.sna.AbstractAdapter;
	import org.shypl.sna.FriendRequest;
	import org.shypl.sna.MakeFriendsRequestHandler;
	import org.shypl.sna.MakePaymentHandler;
	import org.shypl.sna.MakeWallPostHandler;
	import org.shypl.sna.SnUser;
	import org.shypl.sna.SnUserGender;
	import org.shypl.sna.SnUserIdListReceiver;
	import org.shypl.sna.SnUserListReceiver;
	import org.shypl.sna.SnaException;
	import org.shypl.sna.WallPost;

	public class VkAdapter extends AbstractAdapter {
		private static const logger:Logger = LogManager.getLogger(VkAdapter);

		private static const USER_FIELDS:String = "uid,first_name,last_name,photo_100,sex";

		private static function createUser(data:Object):SnUser {
			try {
				return new SnUser(
					data.uid,
					data.first_name,
					data.last_name,
					data.photo_100,
					(data.sex == 1) ? SnUserGender.FEMALE : ((data.sex == 2) ? SnUserGender.MALE : SnUserGender.UNDEFINED));
			}
			catch (e:Error) {
				throw new SnaException("Can't create SocialNetworkUser (" + e.message + ")", e);
			}

			return null;
		}

		private static function createUserList(data:Array):Vector.<SnUser> {
			const list:Vector.<SnUser> = new Vector.<SnUser>(data.length, true);
			for (var i:int = 0; i < data.length; i++) {
				list[i] = createUser(data[i]);
			}
			return list;
		}

		private var _testMode:Boolean;
		private var _makePaymentHandler:MakePaymentHandler;
		private var _makeFriendsRequestHandler:MakeFriendsRequestHandler;

		public function VkAdapter(stage:Stage, sessionUserId:String, testMode:Boolean) {
			super(1, 1000, stage, sessionUserId);
			_testMode = testMode;

			ExternalInterface.addCallback("__sna_callbackApi", callbackApi);
			ExternalInterface.addCallback("__sna_callbackClient", callbackClient);
		}

		override public function getCurrencyLabelForNumber(number:Number):String {
			return NumberUtils.defineWordDeclinationRu(number, "голос", "голоса", "голосов");
		}

		override protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			callApi("users.get", {uids: ids.join(","), fields: USER_FIELDS}, receiver);
		}

		override protected function doGetFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			callApi("friends.get", {fields: USER_FIELDS, count: limit, offset: offset}, receiver);
		}

		override protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			callApi("friends.getAppUsers", null, receiver);
		}

		override protected function doInviteFriends():void {
			closeFullScreen();
			callClient("showInviteBox");
		}

		override protected function doMakePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			if (_makePaymentHandler) {
				throw new IllegalStateException();
			}
			_makePaymentHandler = handler;

			closeFullScreen();
			callClient("showOrderBox", [{type: "item", item: id}]);
		}

		override protected function doMakeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			callApi("wall.post", {owner_id: sessionUserId, message: post.message, attachments: post.image}, handler);
		}

		override protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			if (_makeFriendsRequestHandler) {
				throw new IllegalStateException();
			}
			_makeFriendsRequestHandler = handler;

			closeFullScreen();
			callClient("showRequestBox", [userId, request.message]);
		}

		private function callApi(method:String, params:Object, handler:Object):void {
			try {
				const callbackId:int = handler == null ? -1 : registerCallbackHandler(handler);

				if (params == null) {
					params = {};
				}

				if (_testMode) {
					params.test_mode = true;
				}

				if (logger.isDebugEnabled()) {
					logger.debug("api > [{}] {}({})", callbackId, method, params);
				}

				ExternalInterface.call("__sna_api", method, params, callbackId);
			}
			catch (e:Error) {
				throw new SnaException("Error on call api", e);
			}
		}

		private function callClient(method:String, params:Array = null):void {
			try {
				if (params == null) {
					params = [];
				}

				if (logger.isDebugEnabled()) {
					logger.debug("client > {}({})", method, params);
				}

				ExternalInterface.call("__sna_client", method, params);
			}
			catch (e:Error) {
				throw new SnaException("Error on call client", e);
			}
		}

		private function callbackApi(callbackId:int, data:Object):void {
			if (logger.isDebugEnabled()) {
				logger.debug("api < [{}] {}", callbackId, data);
			}

			try {
				const handler:Object = getCallbackHandler(callbackId);

				if (data.error) {
					if (handler is MakeWallPostHandler) {
						MakeWallPostHandler(handler).handleMakeWallPostResult(false);
					}
					else {
						throw new SnaException("Error when calling api (" + data.error.error_msg + " [" + data.error.error_code + "])");
					}
				}
				else {
					data = data.response;

					if (handler is SnUserListReceiver) {
						SnUserListReceiver(handler).receiverSnUserList(createUserList(data as Array));
					}
					else if (handler is SnUserIdListReceiver) {
						SnUserIdListReceiver(handler).receiverSnUserIdList(CollectionUtils.arrayToVector(data as Array, String) as Vector.<String>);
					}
					else if (handler is MakeWallPostHandler) {
						MakeWallPostHandler(handler).handleMakeWallPostResult(!!data);
					}
				}
			}
			catch (e:Error) {
				throw new SnaException("Error on handle api callback", e);
			}
		}

		private function callbackClient(type:String, success:Boolean):void {
			logger.debug("client < {}:{}", type, success);

			try {
				switch (type) {
					case "payment":
						if (_makePaymentHandler) {
							_makePaymentHandler.handleMakePaymentResult(success);
							_makePaymentHandler = null;
						}
						break;
					case "friendsRequest":
						if (_makeFriendsRequestHandler) {
							_makeFriendsRequestHandler.handleMakeFriendRequestResult(success);
							_makeFriendsRequestHandler = null;
						}
						break;
				}

			}
			catch (e:Error) {
				throw new SnaException("Error on handle call callback", e);
			}
		}
	}
}
