package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.JsAdapterCreator;
	import org.shypl.sna.SocialNetworkAdapter;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class FbAdapterCreator extends JsAdapterCreator {
		public function FbAdapterCreator(receiver:SocialNetworkAdapterReceiver, stage:Stage, sessionUserId:String) {
			super(receiver, stage, sessionUserId);
		}
		
		override protected function getJsCode():String {
			return null;
		}
		
		override protected function getAdapter(stage:Stage, sessionUserId:String):SocialNetworkAdapter {
			return null;
		}
	}
}
