package org.shypl.sna {
	internal class CallQueueItem {
		private var _method:Function;
		private var _args:Array;

		public function CallQueueItem(method:Function, args:Array) {
			_method = method;
			_args = args;
		}

		public function execute():void {
			_method.apply(null, _args);
			_method = null;
			_args = null;
		}
	}
}
