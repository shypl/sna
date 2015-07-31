package org.shypl.sna {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.AbstractMethodException;

	[Abstract]
	public class JsAdapterCreator {
		private var _receiver:AdapterReceiver;
		private var _stage:Stage;
		private var _sessionUserId:String;
		private var _jsArgs:Array;

		public function JsAdapterCreator(receiver:AdapterReceiver, stage:Stage, sessionUserId:String, jsArgs:Array = null) {
			_receiver = receiver;
			_stage = stage;
			_sessionUserId = sessionUserId;
			_jsArgs = jsArgs == null ? [] : jsArgs;

			try {
				start();
			}
			catch (e:Error) {
				new SnaException("Сan not create adapter", e);
			}
		}

		[Abstract]
		protected function getJsCode():String {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function getAdapter(stage:Stage, sessionUserId:String):Adapter {
			throw new AbstractMethodException();
		}

		private function start():void {
			ExternalInterface.addCallback("__sna_completeInit", complete);

			var args:Array = [
				getJsCode(),
				ExternalInterface.objectID
			];

			for each (var arg:Object in _jsArgs) {
				args.push(arg);
			}

			ExternalInterface.call.apply(null, args);
		}

		private function complete():void {
			if (_receiver != null) {
				_receiver.receiveAdapter(getAdapter(_stage, _sessionUserId));
				_receiver = null;
				_stage = null;
				_sessionUserId = null;
				_jsArgs = null;
			}
		}
	}
}
