package org.shypl.sna
{
	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.lang.IllegalArgumentException;
	import org.shypl.common.lang.NullPointerException;
	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;

	[Abstract]
	public class SocialNetworkAdapter
	{
		public static function factoryByServerParams(errorHandler:IErrorHandler, params:String):SocialNetworkAdapter
		{
			const paramsArray:Array = params.split(";");
			const paramsObject:Object = {};
			const name:String = paramsArray.shift();

			for each (var entry:String in paramsArray) {
				var i:int = entry.indexOf("=");
				paramsObject[entry.substr(0, i)] = entry.substr(i + 1);
			}

			return factory(name, errorHandler, paramsObject);
		}

		public static function factory(name:String, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter
		{
			if (name == null) {
				throw new NullPointerException();
			}

			const n:String = name.toLowerCase();

			for each (var network:Network in Network._list) {
				if (n == network.name) {
					return network.createAdapter(errorHandler, params);
				}
			}

			throw new IllegalArgumentException("Undefined social network (" + name + ")");
		}

		private var _network:Network;
		private var _sessionUserId:String;
		private var _errorHandler:IErrorHandler;

		public function SocialNetworkAdapter(network:Network, sessionUserId:String, errorHandler:IErrorHandler)
		{
			if (network === null) {
				throw new IllegalArgumentException("network");
			}
			if (StringUtils.isEmpty(sessionUserId, true)) {
				throw new IllegalArgumentException("sessionUserId");
			}
			if (errorHandler === null) {
				throw new IllegalArgumentException("errorHandler");
			}

			_network = network;
			_sessionUserId = sessionUserId;
			_errorHandler = errorHandler;
		}

		public function get network():Network
		{
			return _network;
		}

		public function get sessionUserId():String
		{
			return _sessionUserId;
		}

		[Abstract]
		public function get api():IApi
		{
			throw new AbstractMethodException();
		}

		protected function get errorHandler():IErrorHandler
		{
			return _errorHandler;
		}
	}
}
