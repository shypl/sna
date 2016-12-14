package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.JsAdapterCreator;
	import org.shypl.sna.SocialNetworkAdapter;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class FbAdapterCreator extends JsAdapterCreator {
		private var appId:String;
		
		public function FbAdapterCreator(receiver:SocialNetworkAdapterReceiver, stage:Stage, sessionUserId:String, appId:String) {
			super(receiver, stage, sessionUserId, [appId]);
			this.appId = appId;
		}
		
		override protected function getJsCode():String {
			return new FbJs().toString();
		}
		
		override protected function getAdapter(stage:Stage, sessionUserId:String):SocialNetworkAdapter {
			return new FbAdapter(stage, sessionUserId, appId);
		}
	}
}
