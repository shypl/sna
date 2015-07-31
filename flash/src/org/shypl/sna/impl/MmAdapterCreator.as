package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.Adapter;
	import org.shypl.sna.AdapterReceiver;
	import org.shypl.sna.JsAdapterCreator;

	public class MmAdapterCreator extends JsAdapterCreator {
		public function MmAdapterCreator(receiver:AdapterReceiver, stage:Stage, sessionUserId:String, privateKey:String) {
			super(receiver, stage, sessionUserId, [privateKey]);
		}

		override protected function getJsCode():String {
			return new MmJs().toString();
		}

		override protected function getAdapter(stage:Stage, sessionUserId:String):Adapter {
			return new MmAdapter(stage, sessionUserId);
		}
	}
}
