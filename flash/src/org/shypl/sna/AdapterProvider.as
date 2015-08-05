package org.shypl.sna {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.IllegalArgumentException;
	import org.shypl.sna.impl.DevAdapter;
	import org.shypl.sna.impl.MmAdapterCreator;
	import org.shypl.sna.impl.OkAdapterCreator;
	import org.shypl.sna.impl.VkAdapterCreator;

	public final class AdapterProvider {
		public static function providerFromEnvironment(receiver:AdapterReceiver, stage:Stage):void {
			if (ExternalInterface.available) {
				provider(receiver, stage, ExternalInterface.call("__sna_fap"));
			}
			else {
				receiver.receiveAdapter(new DevAdapter('DEV-1'));
			}
		}

		public static function provider(receiver:AdapterReceiver, stage:Stage, parameters:Object):void {
			switch (parameters.aid) {
				case 1:
					new VkAdapterCreator(receiver, stage, parameters.uid, parameters.tm);
					break;
				case 2:
					new MmAdapterCreator(receiver, stage, parameters.uid, parameters.pk);
					break;
				case 3:
					new OkAdapterCreator(receiver, stage, parameters.uid);
					break;
				default:
					throw new IllegalArgumentException();
			}

		}
	}
}
