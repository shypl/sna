package org.shypl.sna
{
	import org.shypl.common.util.IErrorHandler;

	public class SocialNetwork
	{
		public static const VK:SocialNetwork = new SocialNetwork(1, "vk", AdapterVk);
		public static const MM:SocialNetwork = new SocialNetwork(2, "mm", AdapterMm);
		public static const OK:SocialNetwork = new SocialNetwork(3, "ok", AdapterOk);

		private static const _list:Vector.<SocialNetwork> = new <SocialNetwork>[VK, MM, OK];

		{
			_list.fixed = true;
		}

		public static function getById(id:int):SocialNetwork
		{
			for each (var network:SocialNetwork in _list) {
				if (network.id == id) {
					return network;
				}
			}
			return null
		}

		public static function getByCode(code:String):SocialNetwork
		{
			for each (var network:SocialNetwork in _list) {
				if (network.code == code) {
					return network;
				}
			}
			return null
		}

		///

		private var _id:int;
		private var _code:String;
		private var _adapterClass:Class;

		public function SocialNetwork(id:int, code:String, adapterClass:Class)
		{
			_id = id;
			_code = code;
			_adapterClass = adapterClass;
		}

		public function get id():int
		{
			return _id;
		}

		public function get code():String
		{
			return _code;
		}

		internal function createAdapter(errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter
		{
			return new _adapterClass(this, errorHandler, params);
		}
	}
}
