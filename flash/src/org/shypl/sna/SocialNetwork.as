package org.shypl.sna {
	import flash.display.Stage;

	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.util.IErrorHandler;

	public class SocialNetwork {
		private var _id:int;
		private var _code:String;
		private var _index:int;

		public function SocialNetwork(id:int, code:String) {
			_id = id;
			_code = code;
			_index = id - 1;
		}

		public function get id():int {
			return _id;
		}

		public function get code():String {
			return _code;
		}

		public function get index():int {
			return _index;
		}

		[Abstract]
		public function defineCurrencyLabel(number:Number):String {
			throw new AbstractMethodException();
		}

		[Abstract]
		internal function createAdapter(stage:Stage, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter {
			throw new AbstractMethodException();
		}
	}
}
