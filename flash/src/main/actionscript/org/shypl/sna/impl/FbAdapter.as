package org.shypl.sna.impl {
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import org.shypl.common.lang.RuntimeException;
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.logging.Logger;
	import org.shypl.common.util.NumberUtils;
	import org.shypl.sna.AbstractAdapter;
	import org.shypl.sna.CallResultHandler;
	import org.shypl.sna.FriendRequest;
	import org.shypl.sna.MakeFriendsRequestHandler;
	import org.shypl.sna.SnUser;
	import org.shypl.sna.SnUserGender;
	import org.shypl.sna.SnUserIdListReceiver;
	import org.shypl.sna.SnUserListReceiver;
	import org.shypl.sna.SnaException;
	
	public class FbAdapter extends AbstractAdapter {
		private static const LOGGER:Logger = LogManager.getLogger(FbAdapter);

		private static function createUser(data:Object):SnUser {
			try {
				var avatar:String = null;
				if (data.picture && data.picture.data && data.picture.data.url) {
					avatar = data.picture.data.url;
				}
				
				return new SnUser(
					data.uid,
					data.first_name,
					data.last_name,
					avatar,
					(data.gender == "male") ? SnUserGender.MALE : ((data.gender == "female") ? SnUserGender.FEMALE : SnUserGender.UNDEFINED));
			}
			catch (e:Error) {
				throw new SnaException("Can't create SocialNetworkUser (" + e.message + ")", e);
			}
			
			return null;
		}
		
		private static function createUserList(map:Object):Vector.<SnUser> {
			const list:Vector.<SnUser> = new Vector.<SnUser>();
			for each (var data:Object in map) {
				list.push(createUser(data));
			}
			return list;
		}
		
		private static function extractSnUserIdList(data:Object):Vector.<String> {
			const list:Vector.<String> = new Vector.<String>();
			for each (var e:Object in data.data) {
				list.push(e.id);
			}
			return list;
		}
		
		private var _appId:String;
		
		public function FbAdapter(stage:Stage, sessionUserId:String, appId:String) {
			super(4, 50, stage, sessionUserId);
			_appId = appId;
			ExternalInterface.addCallback("__sna_api", handleApiCallback);
			ExternalInterface.addCallback("__sna_ui", handleUiCallback);
		}
		
		override public function getCurrencyLabelForNumber(number:Number):String {
			return NumberUtils.defineWordDeclinationRu(number, "fb", "fb", "fb");
		}
		
		override public function call(method:String, params:Object, handler:CallResultHandler):void {
			callApi(method, 'get', params, handler);
		}
		
		override protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			callApi("", "get", {ids: ids.join(","), fields: "id,first_name,last_name,gender,picture"}, receiver);
		}
		
		override protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			callApi("me/friends", "get", {fields: "id"}, receiver);
		}
		
		override protected function doInviteFriends():void {
			closeFullScreen();
			callUi({method: "apprequests"}, null);
		}
		
		override protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			closeFullScreen();
			callUi({method: "send", link: "https://apps.facebook.com/" + _appId, to: userId}, null);
			handler.handleMakeFriendRequestResult(true);
		}
		
		private function callApi(path:String, method:String, params:Object, callback:Object):void {
			try {
				var callbackId:int = registerCallbackHandler(callback);
				
				if (params == null) {
					params = {};
				}
				
				if (LOGGER.isDebugEnabled()) {
					LOGGER.debug("api > [{}] {}({})", callbackId, path, params);
				}
				
				ExternalInterface.call("__sna_api", path, method, params, callbackId);
			}
			catch (e:Error) {
				throw new SnaException("Error on call api", e);
			}
		}
		
		private function callUi(params:Object, callback:Object):void {
			var callbackId:int = registerCallbackHandler(callback);
			
			if (LOGGER.isDebugEnabled()) {
				LOGGER.debug("ui > [{}] {}", callbackId, params);
			}
			
			ExternalInterface.call("__sna_ui", params, callbackId);
		}
		
		private function handleApiCallback(callbackId:int, data:Object):void {
			try {
				if (LOGGER.isDebugEnabled()) {
					LOGGER.debug("api < [{}] {}", callbackId, data);
				}
				
				var callback:Object = getCallbackHandler(callbackId);
				
				if (data.error) {
					throw new RuntimeException("Bad api call: " + data.error.message);
				}
				else {
					if (callback is SnUserListReceiver) {
						SnUserListReceiver(callback).receiverSnUserList(createUserList(data));
					}
					else if (callback is SnUserIdListReceiver) {
						SnUserIdListReceiver(callback).receiverSnUserIdList(extractSnUserIdList(data));
					}
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle api callback", e));
			}
		}
		
		private function handleUiCallback(callbackId:int, data:Object):void {
			try {
				if (LOGGER.isDebugEnabled()) {
					LOGGER.debug("ui < [{}] {}", callbackId, data);
				}
				
				var callback:Object = getCallbackHandler(callbackId);
				
				if (data.error_message) {
					throw new RuntimeException("Bad api call: " + data.error_message);
				}
				else {
					
				}
			}
			catch (e:Error) {
				throwExceptionDelayed(new SnaException("Error on handle api callback", e));
			}
		}
	}
}
