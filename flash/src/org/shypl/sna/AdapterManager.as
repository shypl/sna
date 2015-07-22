package org.shypl.sna {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.lang.IllegalArgumentException;
	import org.shypl.sna.impl.DevAdapter;
	import org.shypl.sna.impl.MmAdapter;
	import org.shypl.sna.impl.OkAdapter;
	import org.shypl.sna.impl.VkAdapter;

	public final class AdapterManager {
		public static function factoryFromEnvironment(stage:Stage):Adapter {
			if (ExternalInterface.available) {
				return factory(stage, ExternalInterface.call("window.SNA_FAP"));
			}
			return new DevAdapter(stage, {uid: 'DEV-1'});
		}

		public static function factory(stage:Stage, parameters:Object):Adapter {
			if (parameters && 'aid' in parameters) {
				switch (parameters.aid) {
					case 1:
						return new VkAdapter(stage, parameters);
					case 2:
						return new MmAdapter(stage, parameters);
					case 3:
						return new OkAdapter(stage, parameters);
				}
			}
			throw new IllegalArgumentException();
		}
	}
}
