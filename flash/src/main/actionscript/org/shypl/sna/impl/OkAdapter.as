package org.shypl.sna.impl {
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.logging.Logger;
	import org.shypl.common.util.CollectionUtils;
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
	
	public class OkAdapter extends AbstractAdapter {
		private static const logger:Logger = LogManager.getLogger(OkAdapter);
		private static const USER_FIELDS:String = "uid,first_name,last_name,pic128x128,gender";
		
		private static function createUser(data:Object):SnUser {
			try {
				return new SnUser(
					data.uid,
					data.first_name, data.last_name,
					data.pic128x128,
					(data.gender == "female")
						? SnUserGender.FEMALE
						: ((data.sex == "male") ? SnUserGender.MALE : SnUserGender.UNDEFINED));
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
		
		private var _handlerMakePayment:MakePaymentHandler;
		private var _handlerMakeFriendsRequest:MakeFriendsRequestHandler;
		private var _handlerMakeWallPost:MakeWallPostHandler;
		private var _friendsRequestUserId:String;
		
		public function OkAdapter(stage:Stage, sessionUserId:String) {
			super(3, 100, stage, sessionUserId);
			
			ExternalInterface.addCallback("__sna_api", handleApiCallback);
			ExternalInterface.addCallback("__sna_payment", handlePaymentCallback);
			ExternalInterface.addCallback("__sna_friendsRequest", handleFriendsRequestCallback);
			ExternalInterface.addCallback("__sna_makeWallPost", handleWallPostCallback);
		}
		
		override public function getCurrencyLabelForNumber(number:Number):String {
			return "ок";
		}
		
		override protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			callApi("users.getInfo", {uids: ids.join(","), fields: USER_FIELDS, emptyPictures: false}, receiver);
		}
		
		override protected function doGetFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			callApi("friends.get", null, new GetFriendsHelper(this, limit, offset, receiver));
		}
		
		override protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			callApi("friends.getAppUsers", null, receiver);
		}
		
		override protected function doInviteFriends():void {
			logger.debug("invite friends >");
			closeFullScreen();
			ExternalInterface.call("FAPI.UI.showInvite");
		}
		
		override protected function doMakePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			if (_handlerMakePayment) {
				_handlerMakePayment.handleMakePaymentResult(false);
			}
			_handlerMakePayment = handler;
			
			logger.debug("payment > id: {}, name: {}, price: {}", id, name, price);
			
			closeFullScreen();
			showVoile(function ():void {
				handlePaymentCallback(false);
			});
			ExternalInterface.call("FAPI.UI.showPayment", name, name, id, price, null, null, "ok", "true");
		}
		
		override protected function doMakeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			if (_handlerMakeWallPost) {
				_handlerMakeWallPost.handleMakeWallPostResult(false);
			}
			_handlerMakeWallPost = handler;
			
			logger.debug("wall post > message: {}", post.message);
			
			closeFullScreen();
			showVoile(function ():void {
				handleWallPostCallback(false);
			});
			ExternalInterface.call("__sna_makeWallPost", post.message);
		}
		
		override protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			if (_handlerMakeFriendsRequest) {
				_handlerMakeFriendsRequest.handleMakeFriendRequestResult(false);
			}
			_handlerMakeFriendsRequest = handler;
			_friendsRequestUserId = userId;
			
			logger.debug("friends request > user: {}, message: {}", userId, request.message);
			
			closeFullScreen();
			showVoile(function ():void {
				handleFriendsRequestCallback(false, null);
			});
			ExternalInterface.call("FAPI.UI.showNotification", request.message, null, userId);
		}
		
		private function callApi(method:String, params:Object, handler:Object):void {
			try {
				const callbackId:int = handler == null ? -1 : registerCallbackHandler(handler);
				
				if (params == null) {
					params = {};
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
		
		private function handleApiCallback(callbackId:int, data:Object):void {
			try {
				if (logger.isDebugEnabled()) {
					logger.debug("api < [{}] {}", callbackId, data);
				}
				
				const handler:Object = getCallbackHandler(callbackId);
				
				if (handler is SnUserListReceiver) {
					SnUserListReceiver(handler).receiverSnUserList(createUserList(data as Array));
				}
				else if (handler is SnUserIdListReceiver) {
					SnUserIdListReceiver(handler)
						.receiverSnUserIdList(CollectionUtils.arrayToVector(("uids" in data ? data.uids : data) as Array, String) as Vector.<String>);
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle api callback", e));
			}
		}
		
		private function handlePaymentCallback(success:Boolean):void {
			try {
				hideVoile();
				logger.debug("payment < {} {}", success);
				if (_handlerMakePayment) {
					_handlerMakePayment.handleMakePaymentResult(success);
					_handlerMakePayment = null;
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle payment callback", e));
			}
		}
		
		private function handleFriendsRequestCallback(success:Boolean, data:Object):void {
			try {
				hideVoile();
				if (logger.isDebugEnabled()) {
					logger.debug("friends request < {} {}", success, data);
				}
				
				if (_handlerMakeFriendsRequest) {
					if (success) {
						success = false;
						if (data is Array) {
							for each (var uid:Object in data) {
								if (uid == _friendsRequestUserId) {
									success = true;
									break;
								}
							}
						}
						else {
							success = data == _friendsRequestUserId;
						}
					}
					_handlerMakeFriendsRequest.handleMakeFriendRequestResult(success);
					_handlerMakeFriendsRequest = null;
					_friendsRequestUserId = null;
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle friends request callback", e));
			}
		}
		
		private function handleWallPostCallback(success:Boolean):void {
			try {
				hideVoile();
				logger.debug("wall post < {}", success);
				
				if (_handlerMakeWallPost) {
					_handlerMakeWallPost.handleMakeWallPostResult(success);
					_handlerMakeWallPost = null;
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle wall post callback", e));
			}
		}
		
	}
}

import org.shypl.sna.SnUserIdListReceiver;
import org.shypl.sna.SnUserListReceiver;
import org.shypl.sna.SocialNetworkAdapter;

class GetFriendsHelper implements SnUserIdListReceiver {
	private var _adapter:SocialNetworkAdapter;
	private var _limit:int;
	private var _offset:int;
	private var _receiver:SnUserListReceiver;
	
	public function GetFriendsHelper(adapter:SocialNetworkAdapter, limit:int, offset:int, receiver:SnUserListReceiver) {
		_adapter = adapter;
		_limit = limit;
		_offset = offset;
		_receiver = receiver;
	}
	
	public function receiverSnUserIdList(list:Vector.<String>):void {
		list = list.slice(_offset, _offset + _limit);
		_adapter.getUsers(list, _receiver);
		_adapter = null;
		_receiver = null;
	}
}