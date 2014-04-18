package org.shypl.sna
{
	import flash.display.Stage;

	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.util.IErrorHandler;

	public class SocialNetwork
	{
		public static const VK:SocialNetwork = new NetworkVk();
		public static const MM:SocialNetwork = new NetworkMm();
		public static const OK:SocialNetwork = new NetworkOk();

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
		private var _index:int;

		public function SocialNetwork(id:int, code:String)
		{
			_id = id;
			_code = code;
			_index = id - 1;
		}

		public function get id():int
		{
			return _id;
		}

		public function get code():String
		{
			return _code;
		}

		public function get index():int
		{
			return _index;
		}

		[Abstract]
		public function defineCurrencyLabel(number:Number):String
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		internal function createAdapter(stage:Stage, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter
		{
			throw new AbstractMethodException();
		}
	}
}
