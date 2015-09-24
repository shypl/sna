package org.shypl.sna.impl {
	import flash.display.Stage;

	import org.shypl.sna.AdapterReceiver;
	import org.shypl.sna.SocialNetwork;

	public class DevSocialNetwork extends SocialNetwork {
		public function DevSocialNetwork() {
			super(0, "dev");
		}

		override public function createAdapter(receiver:AdapterReceiver, stage:Stage, parameters:Object):void {
			receiver.receiveAdapter(new DevAdapter('DEVELOPER'));
		}
	}
}
