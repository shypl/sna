package org.shypl.sna.impl {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.IllegalStateException;
	import org.shypl.common.util.CollectionUtils;
	import org.shypl.common.util.NumberUtils;
	import org.shypl.sna.Adapter;
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

	public class MmAdapter extends Adapter {
		private static function createUser(data:Object):SnUser {
			try {
				return new SnUser(
					data.uid,
					data.first_name,
					data.last_name,
					data.pic,
					(data.sex == 1) ? SnUserGender.FEMALE : ((data.sex == 0) ? SnUserGender.MALE : SnUserGender.UNDEFINED));
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

		private var _privateKey:String;
		private var _handlerMakePayment:MakePaymentHandler;
		private var _handlerMakeFriendsRequest:MakeFriendsRequestHandler;
		private var _handlerMakeWallPost:MakeWallPostHandler;
		private var _friendsRequestUserId:String;

		public function MmAdapter(stage:Stage, parameters:Object) {
			super(stage, 2, parameters, 200);
			_privateKey = parameters.pk;
		}

		override public function getCurrencyLabelForNumber(number:Number):String {
			return NumberUtils.defineWordDeclinationRu(number, "мелик", "мейлика", "мейликов");
		}

		override protected function init():void {
			ExternalInterface.addCallback("__sna_api", handleApiCallback);
			ExternalInterface.addCallback("__sna_payment", handlePaymentCallback);
			ExternalInterface.addCallback("__sna_friendsRequest", handleFriendsRequestCallback);
			ExternalInterface.addCallback("__sna_wallPost", handleWallPostCallback);
			ExternalInterface.call(new MmAdapterJs().toString(), ExternalInterface.objectID, _privateKey);
		}

		override protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			callApi("common.users.getInfo", [CollectionUtils.vectorToArray(ids)], receiver);
		}

		override protected function doGetFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			callApi("common.friends.getExtended", [sessionUserId, offset], new GetFriendsHelper(receiver, limit));
		}

		override protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			callApi("common.friends.getAppUsers", null, receiver);
		}

		override protected function doInviteFriends():void {
			closeFullScreen();
			callApi("app.friends.invite", null, null);
		}

		override protected function doMakePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			if (_handlerMakePayment) {
				throw new IllegalStateException();
			}
			_handlerMakePayment = handler;

			closeFullScreen();
			callApi("app.payments.showDialog", [{service_id: id, service_name: name, mailiki_price: price}], null);
		}

		override protected function doMakeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			if (_handlerMakeWallPost) {
				throw new IllegalStateException();
			}
			_handlerMakeWallPost = handler;

			closeFullScreen();
			callApi("common.stream.post", [{text: post.message, img_url: post.image}], null);
		}

		override protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			if (_handlerMakeFriendsRequest) {
				throw new IllegalStateException();
			}
			_handlerMakeFriendsRequest = handler;
			_friendsRequestUserId = userId;

			closeFullScreen();
			callApi("app.friends.request", [{text: request.message, image_url: request.image, friends: [userId]}], null);
		}

		private function callApi(method:String, params:Array, handler:Object):void {
			try {
				const callbackId:int = registerCallbackHandler(handler);

				if (params == null) {
					params = [];
				}

				logger.debug("api > [{}] {}({})", callbackId, method, params);

				ExternalInterface.call("__sna_api", method, params, callbackId);
			}
			catch (e:Error) {
				catchException(new SnaException("Error on call api", e));
			}
		}

		private function handleApiCallback(callbackId:int, data:Object):void {
			logger.debug("api < [{}] {}", callbackId, data);

			try {
				if (data.error) {
					throw new SnaException("Error when calling api (" + data.error.error_msg + " [" + data.error.error_code + "])");
				}
				data = data.response;
				const handler:Object = getCallbackHandler(callbackId);

				if (handler is SnUserListReceiver) {
					SnUserListReceiver(handler).receiverSnUserList(createUserList(data as Array));
				}
				else if (handler is SnUserIdListReceiver) {
					SnUserIdListReceiver(handler).receiverSnUserIdList(CollectionUtils.arrayToVector(data as Array, String) as Vector.<String>);
				}
			}
			catch (e:Error) {
				catchException(new SnaException("Error on handle api callback", e));
			}
		}

		private function handlePaymentCallback(success:Boolean):void {
			logger.debug("payment < {}", success);

			try {
				if (_handlerMakePayment) {
					_handlerMakePayment.handleMakePaymentResult(success);
					_handlerMakePayment = null;
				}
			}
			catch (e:Error) {
				catchException(new SnaException("Error on handle payment", e));
			}
		}

		private function handleFriendsRequestCallback(data:Object):void {
			logger.debug("friends request < {}", data);

			if (_handlerMakeFriendsRequest) {
				var success:Boolean = false;
				if (data is Array) {
					for each (var uid:Object in data) {
						if (uid == _friendsRequestUserId) {
							success = true;
							break;
						}
					}
				}
				_handlerMakeFriendsRequest.handleMakeFriendRequestResult(success);
				_handlerMakeFriendsRequest = null;
				_friendsRequestUserId = null;
			}
		}

		private function handleWallPostCallback(success:Boolean):void {
			logger.debug("wall post < {}", success);

			try {
				if (_handlerMakeWallPost) {
					_handlerMakeWallPost.handleMakeWallPostResult(success);
					_handlerMakeWallPost = null;
				}
			}
			catch (e:Error) {
				catchException(new SnaException("Error on handle payment", e));
			}
		}
	}
}
import org.shypl.sna.SnUser;
import org.shypl.sna.SnUserListReceiver;

class GetFriendsHelper implements SnUserListReceiver {
	private var _receiver:SnUserListReceiver;
	private var _limit:int;

	public function GetFriendsHelper(handler:SnUserListReceiver, limit:int) {
		_receiver = handler;
		_limit = limit;
	}

	public function receiverSnUserList(list:Vector.<SnUser>):void {
		_receiver.receiverSnUserList(list.slice(0, _limit));
		_receiver = null;
	}
}