package org.shypl.sna {
	internal class CallQueueItem {
		private var _closure:Function;
		private var _args:Array;
		
		public function CallQueueItem(closure:Function, args:Array) {
			_closure = closure;
			_args = args;
		}
		
		public function execute():void {
			_closure.apply(null, _args);
			_closure = null;
			_args = null;
		}
	}
}
