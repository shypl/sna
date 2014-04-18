package org.shypl.sna
{
	import flash.display.Stage;

	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterOk extends SocialNetworkAdapter
	{
		public function AdapterOk(stage:Stage, network:SocialNetwork, errorHandler:IErrorHandler, params:Object)
		{
			super(stage, errorHandler, network, params, LogManager.getByClass(AdapterOk));
		}
	}
}
