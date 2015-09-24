package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.AdapterReceiver;
	import org.shypl.sna.SocialNetwork;

	public class OkSocialNetwork extends SocialNetwork {
		public function OkSocialNetwork() {
			super(3, "ok");
		}

		override public function createAdapter(receiver:AdapterReceiver, stage:Stage, parameters:Object):void {
			new OkAdapterCreator(receiver, stage, parameters.uid);
		}
	}
}
