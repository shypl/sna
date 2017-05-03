package org.shypl.sna.impl {
	import flash.display.Stage;
	
	import org.shypl.sna.SocialNetwork;
	import org.shypl.sna.SocialNetworkAdapterReceiver;
	
	public class MmSocialNetwork extends SocialNetwork {
		public function MmSocialNetwork() {
			super(2, "mm");
		}
		
		override public function createAdapter(receiver:SocialNetworkAdapterReceiver, stage:Stage, parameters:Object):void {
			new MmAdapterCreator(receiver, stage, parameters.uid, parameters.pk);
		}
	}
}
