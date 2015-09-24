package org.shypl.sna {
	import flash.display.Stage;

	import org.shypl.common.lang.AbstractMethodException;

	[Abstract]
	public class SocialNetwork {
		private var _id:int;
		private var _name:String;

		public function SocialNetwork(id:int, name:String) {
			_id = id;
			_name = name;
		}

		public function get id():int {
			return _id;
		}

		public function get name():String {
			return _name;
		}

		[Abstract]
		public function createAdapter(receiver:AdapterReceiver, stage:Stage, parameters:Object):void {
			throw new AbstractMethodException();
		}
	}
}
