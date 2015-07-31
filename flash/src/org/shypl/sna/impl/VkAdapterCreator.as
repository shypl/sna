package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.Adapter;
	import org.shypl.sna.AdapterReceiver;
	import org.shypl.sna.JsAdapterCreator;

	public class VkAdapterCreator extends JsAdapterCreator {
		private var _testMode:Boolean;

		public function VkAdapterCreator(receiver:AdapterReceiver, stage:Stage, sessionUserId:String, testMode:Boolean) {
			super(receiver, stage, sessionUserId);
			_testMode = testMode;
		}

		override protected function getJsCode():String {
			return new VkJs().toString();
		}

		override protected function getAdapter(stage:Stage, sessionUserId:String):Adapter {
			return new VkAdapter(stage, sessionUserId, _testMode);
		}
	}
}
