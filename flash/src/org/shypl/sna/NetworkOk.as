package org.shypl.sna {
	import flash.display.Stage;

	import org.shypl.common.util.IErrorHandler;

	internal class NetworkOk extends SocialNetwork {
		public function NetworkOk() {
			super(3, "ok");
		}

		override public function defineCurrencyLabel(number:Number):String {
			return "ок";
		}

		override internal function createAdapter(stage:Stage, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter {
			return new AdapterVk(stage, errorHandler, params);
		}
	}
}
