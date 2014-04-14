package org.shypl.sna
{
	import flash.external.ExternalInterface;

	import org.shypl.common.logging.ILogger;
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.StringUtils;

	internal class AdapterVk extends SocialNetworkAdapter
	{
		private static const logger:ILogger = LogManager.getByClass(AdapterVk);
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

		public function AdapterVk(network:SocialNetwork, params:Object)
		{
			super(network, params);
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

		private function catchError(error:SocialNetworkError):void
		{
			logger.error(error.message);
			throw error;
		}

		private function callApi(method:String, params:Object, handler:Object):void
		{
			const callbackId:int = registerCallbackHandler(handler);

			logger.debug("Call api [{}] {}({})", callbackId, method, params);

			try {
				ExternalInterface.call("__sna_api", method, params, callbackId);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Can not call api (" + e.message + ")", e));
			}
		}

		private function handleApiCallback(callbackId:int, data:Object):void
		{
			logger.debug("Api callback [{}] {}", callbackId, data);

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
				catchError(new SocialNetworkError("Can not handle api callback (" + e.message + ")", e));
			}
		}

		private function init0():void
		{
			logger.info("Initialization start");
			try {
				ExternalInterface.addCallback("__sna_inited", init1);
				ExternalInterface.addCallback("__sna_api_callback", handleApiCallback);
				ExternalInterface.call(new AdapterVkJs().toString(), ExternalInterface.objectID);
			}
			catch (e:Error) {
				catchError(new SocialNetworkError("Initialization interrupted (" + e.message + ")", e));
			}
		}

		private function init1():void
		{
			logger.info("Initialization complete");
			completeInit();
		}
	}
}
