package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.SocialNetworkAdapterReceiver;
	import org.shypl.sna.SocialNetwork;

	public class VkSocialNetwork extends SocialNetwork {
		public function VkSocialNetwork() {
			super(1, "vk");
		}

		override public function createAdapter(receiver:SocialNetworkAdapterReceiver, stage:Stage, parameters:Object):void {
			new VkAdapterCreator(receiver, stage, parameters.uid, parameters.tm);
		}
	}
}
