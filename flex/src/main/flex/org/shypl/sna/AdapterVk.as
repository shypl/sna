package org.shypl.sna
{
	import org.shypl.common.lang.IllegalArgumentException;
	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;

	internal class AdapterVk extends SocialNetworkAdapter implements IErrorHandler
	{
		private var _api:ApiVk;
		private var _apiConnectionName:String;
		private var _testMode:Boolean;

		public function AdapterVk(network:Network, errorHandler:IErrorHandler, params:Object)
		{
			super(network, params.uid, errorHandler);

			if (StringUtils.isEmpty(params.acn, true)) {
				throw new IllegalArgumentException();
			}

			_apiConnectionName = params.acn;
			_testMode = params.tm;
		}

		override public function get api():IApi
		{
			if (_api) {
				return _api;
			}
			return _api = new ApiVk(this, _testMode, _apiConnectionName, sessionUserId);
		}

		public function handleError(error:Error):void
		{
			_api = null;
			errorHandler.handleError(error);
		}
	}
}
