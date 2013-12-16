package org.shypl.sna
{
	import org.shypl.common.util.IErrorHandler;

	public final class Network
	{
		internal static const _list:Vector.<Network> = new Vector.<Network>();

		public static const VK:Network = new Network(1, "vk", AdapterVk);
		public static const MM:Network = new Network(2, "mm", AdapterMm);
		public static const OK:Network = new Network(3, "ok", AdapterOk);

		///
		private var _id:int;
		private var _name:String;
		private var _adapterClass:Class;

		public function Network(id:int, name:String, adapterClass:Class)
		{
			_id = id;
			_name = name;
			_adapterClass = adapterClass;
			_list.push(this);
		}

		public function get id():int
		{
			return _id;
		}

		public function get name():String
		{
			return _name;
		}

		internal function createAdapter(errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter
		{
			return new _adapterClass(this, errorHandler, params);
		}
	}
}
