package org.shypl.sna
{
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.IllegalStateException;
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;
	import org.shypl.sna.js.AdapterVkJs;

	internal class AdapterVk extends SocialNetworkAdapter
	{
		private static const USER_FIELDS:String = "uid,first_name,last_name,photo_100,sex";

		private static function createUser(data:Object):SocialNetworkUser
		{
			try {
				return new SocialNetworkUser(
					data.uid,
					StringUtils.trim(data.first_name + " " + data.last_name),
					data.photo_100,
					(data.sex == 1)
						? SocialNetworkUser.GENDER_FEMALE
						: ((data.sex == 2) ? SocialNetworkUser.GENDER_MALE : SocialNetworkUser.GENDER_UNDEFINED));
			}
			catch (e:Error) {
				throw new SocialNetworkError("Can't create SocialNetworkUser (" + e.message + ")", e);
			}

			return null;
		}

		private static function createUserList(data:Array):Vector.<SocialNetworkUser>
		{
			const list:Vector.<SocialNetworkUser> = new Vector.<SocialNetworkUser>(data.length, true);
			for (var i:int = 0; i < data.length; i++) {
				list[i] = createUser(data[i]);
			}
			return list;
		}

		///

		private var _testMode:Boolean;
		private var _handlerMakePayment:IMakePaymentHandler;

		public function AdapterVk(stage:Stage, errorHandler:IErrorHandler, params:Object)
		{
			super(stage, errorHandler, network, params, LogManager.getByClass(AdapterVk));
			_testMode = params.tm;
			init0();
		}

		override protected function doDestroy():void
		{
			super.doDestroy();
		}

		override protected function doGetUsers(ids:Vector.<String>, handler:IUserListHandler):void
		{
			callApi("users.get", {uids: ids.join(","), fields: USER_FIELDS}, handler);
		}

		override protected function doGetFriends(limit:int, offset:int, handler:IUserListHandler):void
		{
			callApi("friends.get", {fields: USER_FIELDS, count: limit, offset: offset}, handler);
		}

		override protected function doGetAppFriendIds(handler:IUserIdListHandler):void
		{
			callApi("friends.getAppUsers", null, handler);
		}

		override protected function doInviteFriends():void
		{
			callClient("showInviteBox");
		}

		override protected function doMakePayment(id:int, name:String, price:int, handler:IMakePaymentHandler):void
		{
			if (_handlerMakePayment) {
				throw new IllegalStateException();
			}

			_handlerMakePayment = handler;
			callClient("showOrderBox", [
				{type: "item", item: id}
			]);
		}

		private function callApi(method:String, params:Object, handler:Object):void
		{
			try {
				const callbackId:int = registerCallbackHandler(handler);

				if (params == null) {
					params = {};
				}

				if (_testMode) {
					params.test_mode = true;
				}

				_logger.debug("Call api [{}] {}({})", callbackId, method, params);

				ExternalInterface.call("__sna_api", method, params, callbackId);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Error on call api", e));
			}
		}

		private function callClient(method:String, params:Array = null):void
		{
			try {
				if (params == null) {
					params = [];
				}
				ExternalInterface.call("__sna_client", method, params);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Error on call client", e));
			}
		}

		private function handleApiCallback(callbackId:int, data:Object):void
		{
			_logger.debug("Callback api [{}] {}", callbackId, data);

			try {
				if (data.error) {
					throw new SocialNetworkError("Error when calling api (" + data.error.error_msg + " [" + data.error.error_code + "])");
				}
				data = data.response;
				const handler:Object = getCallbackHandler(callbackId);

				if (handler is IUserListHandler) {
					IUserListHandler(handler).handleUserList(createUserList(data as Array));
				}
				else if (handler is IUserIdListHandler) {
					IUserIdListHandler(handler).handleUserIdList(Utils.arrayToStringVector(data as Array));
				}
			}
			catch (e:SocialNetworkError) {
				catchError(e);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Error on handle api callback", e));
			}
		}

		private function handlePaymentCallback(success:Boolean, error:int):void
		{
			try {
				if (!success && error != 0) {
					_logger.warn("Payment error {}", error);
				}
				if (_handlerMakePayment) {
					_handlerMakePayment.handleMakePayment(success);
					_handlerMakePayment = null;
				}
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Error on handle payment", e));
			}
		}

		private function init0():void
		{
			_logger.info("Initialization start");
			try {
				ExternalInterface.addCallback("__sna_inited", init1);
				ExternalInterface.addCallback("__sna_api", handleApiCallback);
				ExternalInterface.addCallback("__sna_payment", handlePaymentCallback);
				ExternalInterface.call(new AdapterVkJs().toString(), ExternalInterface.objectID);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Initialization interrupted", e));
			}
		}

		private function init1():void
		{
			try {
				_logger.info("Initialization complete");
				completeInit();
			}
			catch (e:SocialNetworkError) {
				catchError(e);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Initialization interrupted", e));
			}
		}
	}
}
