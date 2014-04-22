package org.shypl.sna {
	import flash.display.Stage;

	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterOk extends SocialNetworkAdapter {
		public function AdapterOk(stage:Stage, errorHandler:IErrorHandler, params:Object) {
			super(stage, errorHandler, SocialNetworkManager.OK, params, LogManager.getByClass(AdapterOk));
		}
	}
}
