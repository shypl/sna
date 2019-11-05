package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.JsAdapterCreator;
	import org.shypl.sna.SocialNetworkAdapter;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class MmAdapterCreator extends JsAdapterCreator {
		public function MmAdapterCreator(receiver: SocialNetworkAdapterReceiver, stage: Stage, sessionUserId: String, privateKey: String) {
			super(receiver, stage, sessionUserId, [privateKey]);
		}
		
		override protected function getJsCode(): String {
			return new MmJs().toString();
		}
		
		override protected function getAdapter(stage: Stage, sessionUserId: String): SocialNetworkAdapter {
			return new MmAdapter(stage, sessionUserId);
		}
	}
}
