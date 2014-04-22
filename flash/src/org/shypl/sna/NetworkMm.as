package org.shypl.sna {
	import flash.display.Stage;

	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;

	internal class NetworkMm extends SocialNetwork {
		public function NetworkMm() {
			super(2, "mm");
		}

		override public function defineCurrencyLabel(number:Number):String {
			return StringUtils.defineNumberDeclinationRu(number, "мелик", "мейлика", "мейликов");
		}

		override internal function createAdapter(stage:Stage, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter {
			return new AdapterVk(stage, errorHandler, params);
		}
	}
}
