package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.SocialNetwork;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class OkSocialNetwork extends SocialNetwork {
		public function OkSocialNetwork() {
			super(3, "ok");
		}
		
		override public function createAdapter(receiver:SocialNetworkAdapterReceiver, stage:Stage, parameters:Object):void {
			new OkAdapterCreator(receiver, stage, parameters.uid);
		}
	}
}
