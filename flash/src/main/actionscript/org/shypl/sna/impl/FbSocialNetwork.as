package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.SocialNetwork;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class FbSocialNetwork extends SocialNetwork {
		public function FbSocialNetwork() {
			super(4, "fb");
		}
		
		override public function createAdapter(receiver:SocialNetworkAdapterReceiver, stage:Stage, parameters:Object):void {
			new FbAdapterCreator(receiver, stage, parameters.uid, parameters.aid);
		}
	}
}
