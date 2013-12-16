package org.shypl.sna
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	import org.shypl.common.lang.EventException;
	import org.shypl.common.lang.IllegalArgumentException;
	import org.shypl.common.lang.RuntimeException;
	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;

	internal class ApiVk implements IApi
	{
		private static const USER_FIELDS:String = "uid,first_name,last_name,photo_100,sex";

		private static function createUser(data:Object):User
		{
			try {
				return new User(
					data.uid,
					StringUtils.trim(data.first_name + " " + data.last_name),
					data.photo_100,
					(data.sex == 1)
						? User.GENDER_FEMALE
						: ((data.sex == 2) ? User.GENDER_MALE : User.GENDER_UNDEFINED));
			}
			catch (e:Error) {
				throw new RuntimeException("Can't create SocialNetworkUser", e);
			}

			return null;
		}

		private static function createUserList(data:Array):Vector.<User>
		{
			const list:Vector.<User> = new Vector.<User>(data.length, true);
			for (var i:int = 0; i < data.length; i++) {
				list[i] = createUser(data[i]);
			}
			return list;
		}

		private static function createUserIdList(data:Array):Vector.<String>
		{
			const list:Vector.<String> = new Vector.<String>(data.length, true);
			for (var i:int = 0; i < data.length; i++) {
				list[i] = data[i];
			}
			return list;
		}

		private var _sender:LocalConnection;
		private var _receiver:LocalConnection;
		private var _connected:Boolean;
		private var _errorHandler:IErrorHandler;
		private var _testMode:Boolean;
		private var _senderName:String;
		private var _sendDataQueue:Vector.<Array> = new Vector.<Array>();
		private var _handlerHolders:Vector.<HandlerHolder> = new Vector.<HandlerHolder>();
		private var _sessionUserId:String;

		public function ApiVk(errorHandler:IErrorHandler, testMode:Boolean, connectionName:String,
			sessionUserId:String)
		{
			_errorHandler = errorHandler;
			_testMode = testMode;
			_sessionUserId = sessionUserId;
			_senderName = "_in_" + connectionName;

			_sender = new LocalConnection();
			_sender.allowDomain('*');

			_receiver = new LocalConnection();
			_receiver.allowDomain('*');
			_receiver.client = {
				initConnection:           initConnection,
				apiCallback:              handleApiResponse,
				customEvent:              handleCustomEvent,
				onBalanceChanged:         handleOnBalanceChanged,
				onSettingsChanged:        handleOnSettingsChanged,
				onLocationChanged:        handleOnLocationChanged,
				onWindowResized:          handleOnWindowResized,
				onApplicationAdded:       handleOnApplicationAdded,
				onWindowBlur:             handleOnWindowBlur,
				onWindowFocus:            handleOnWindowFocus,
				onWallPostSave:           handleOnWallPostSave,
				onWallPostCancel:         handleOnWallPostCancel,
				onProfilePhotoSave:       handleOnProfilePhotoSave,
				onProfilePhotoCancel:     handleOnProfilePhotoCancel,
				onMerchantPaymentSuccess: handleOnMerchantPaymentSuccess,
				onMerchantPaymentCancel:  handleOnMerchantPaymentCancel,
				onMerchantPaymentFail:    handleOnMerchantPaymentFail
			};

			try {
				_receiver.connect("_out_" + connectionName);
			}
			catch (e:Error) {
				throw new RuntimeException("Can't connect to API", e);
			}

			_sender.addEventListener(StatusEvent.STATUS, handleSenderEvent);
			_sender.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleSenderEvent);
			_sender.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSenderEvent);

			_sender.send(_senderName, "initConnection");
		}

		public function destroy():void
		{
			doDestroy(null);
		}

		public function getSessionUser(handler:IUserHandler):void
		{
			getUser(_sessionUserId, handler);
		}

		public function getUser(id:String, handler:IUserHandler):void
		{
			callApi("users.get", {uids: id, fields: USER_FIELDS}, new HandlerHolder(HandlerHolder.USER, handler));
		}

		public function getUsers(ids:Vector.<String>, handler:IUserListHandler):void
		{
			callApi("users.get", {uids: ids.join(","), fields: USER_FIELDS},
				new HandlerHolder(HandlerHolder.USER_LIST, handler));
		}

		public function getFriends(limit:int, offset:int, handler:IUserListHandler):void
		{
			callApi("friends.get", {uid: _sessionUserId, fields: USER_FIELDS, count: limit, offset: offset},
				new HandlerHolder(HandlerHolder.USER_LIST, handler));
		}

		public function getAppFriends(handler:IUserIdListHandler):void
		{
			callApi("friends.getAppUsers", {}, new HandlerHolder(HandlerHolder.USER_ID_LIST, handler));
		}

		private function callApi(method:String, params:Object, holder:HandlerHolder):void
		{
			if (_testMode) {
				params.test_mode = true;
			}
			sendData(["api", _handlerHolders.push(holder), method, params]);
		}

		private function handleApiResponse(callId:int, data:Object):void
		{
			try {
				var len:uint = _handlerHolders.length;

				if (callId < 0 || callId > len) {
					throw new IllegalArgumentException("Illegal callback handler id: " + callId);
				}

				const holder:HandlerHolder = _handlerHolders[--callId];

				_handlerHolders[callId] = null;
				while (len > 0) {
					if (_handlerHolders[--len] !== null) {
						++len;
						break;
					}
				}
				_handlerHolders.length = len;

				//

				if (data.response) {
					data = data.response;
				}
				else if (data.error) {
					throw new RuntimeException("Error response: " + data.error.error_msg
						+ " (" + data.error.error_code + ")");
				}
				else {
					throw new RuntimeException("Invalid response: " + data);
				}

				//
				switch (holder.type) {
					case HandlerHolder.USER:
						IUserHandler(holder.handler).handleUser(createUser(data[0]));
						break;
					case HandlerHolder.USER_LIST:
						IUserListHandler(holder.handler).handleUserList(createUserList(data as Array));
						break;
					case HandlerHolder.USER_ID_LIST:
						IUserIdListHandler(holder.handler).handleUserIdList(createUserIdList(data as Array));
						break;
				}
			}
			catch (e:Error) {
				doDestroy(new ApiException("Can not handle social network response", e));
			}
		}

		private function sendData(data:Array):void
		{
			data.unshift(_senderName);
			if (_connected) {
				_sender.send.apply(_sender.send, data);
			}
			else {
				_sendDataQueue.push(data);
			}
		}

		private function initConnection():void
		{
			if (_connected) {
				return;
			}
			_connected = true;

			for (var i:int = 0; i < _sendDataQueue.length; i++) {
				_sender.send.apply(_sender.send, _sendDataQueue[i]);
				_sendDataQueue[i] = null;
			}
			_sendDataQueue.length = 0;
			_sendDataQueue = null;
		}

		private function doDestroy(error:Error):void
		{
			_sender.removeEventListener(StatusEvent.STATUS, handleSenderEvent);
			_sender.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handleSenderEvent);
			_sender.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSenderEvent);

			try {
				_sender.close();
			}
			catch (e:Error) {
			}
			try {
				_receiver.close();
			}
			catch (e:Error) {
			}

			_sender = null;
			_receiver = null;
			_senderName = null;
			if (_sendDataQueue) {
				_sendDataQueue.length = 0;
				_sendDataQueue = null;
			}

			for each (var handlerHolder:HandlerHolder in _handlerHolders) {
				if (handlerHolder) {
					handlerHolder.handler = null;
				}
			}
			_handlerHolders.length = 0;
			_handlerHolders = null;

			_sessionUserId = null;

			if (error) {
				_errorHandler.handleError(error);
			}
			_errorHandler = null;
		}

		public function handleCustomEvent(name:String, ...params):void
		{
			//TODO
			trace("TODO: sna.ApiVk.handleCustomEvent(" + name + ", " + params + ")");
		}

		private function handleOnBalanceChanged(...params):void
		{
			params.unshift('onBalanceChanged');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnSettingsChanged(...params):void
		{
			params.unshift('onSettingsChanged');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnLocationChanged(...params):void
		{
			params.unshift('onLocationChanged');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnWindowResized(...params):void
		{
			params.unshift('onWindowResized');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnApplicationAdded(...params):void
		{
			params.unshift('onApplicationAdded');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnWindowBlur(...params):void
		{
			params.unshift('onWindowBlur');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnWindowFocus(...params):void
		{
			params.unshift('onWindowFocus');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnWallPostSave(...params):void
		{
			params.unshift('onWallPostSave');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnWallPostCancel(...params):void
		{
			params.unshift('onWallPostCancel');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnProfilePhotoSave(...params):void
		{
			params.unshift('onProfilePhotoSave');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnProfilePhotoCancel(...params):void
		{
			params.unshift('onProfilePhotoCancel');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnMerchantPaymentSuccess(...params):void
		{
			params.unshift('onMerchantPaymentSuccess');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnMerchantPaymentCancel(...params):void
		{
			params.unshift('onMerchantPaymentCancel');
			handleCustomEvent.apply(this, params);
		}

		private function handleOnMerchantPaymentFail(...params):void
		{
			params.unshift('onMerchantPaymentFail');
			handleCustomEvent.apply(this, params);
		}

		private function handleSenderEvent(event:Event):void
		{
			if (event is StatusEvent && StatusEvent(event).level == "status") {
				initConnection();
				return;
			}

			doDestroy(new ApiException("Can't connect to social network", new EventException(event)));
		}
	}
}
