package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.JsAdapterCreator;
	import org.shypl.sna.SocialNetworkAdapter;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class VkAdapterCreator extends JsAdapterCreator {
		private var _testMode: Boolean;
		
		public function VkAdapterCreator(receiver: SocialNetworkAdapterReceiver, stage: Stage, sessionUserId: String, testMode: Boolean) {
			super(receiver, stage, sessionUserId);
			_testMode = testMode;
		}
		
		override protected function getJsCode(): String {
			return new VkJs().toString();
		}
		
		override protected function getAdapter(stage: Stage, sessionUserId: String): SocialNetworkAdapter {
			return new VkAdapter(stage, sessionUserId, _testMode);
		}
	}
}
