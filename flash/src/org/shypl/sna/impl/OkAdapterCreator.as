package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.Adapter;
	import org.shypl.sna.AdapterReceiver;
	import org.shypl.sna.JsAdapterCreator;

	public class OkAdapterCreator extends JsAdapterCreator {
		public function OkAdapterCreator(receiver:AdapterReceiver, stage:Stage, sessionUserId:String) {
			super(receiver, stage, sessionUserId);
		}

		override protected function getJsCode():String {
			return new OkJs().toString();
		}

		override protected function getAdapter(stage:Stage, sessionUserId:String):Adapter {
			return new OkAdapter(stage, sessionUserId);
		}
	}
}
