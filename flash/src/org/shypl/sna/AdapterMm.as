package org.shypl.sna
{
	import flash.display.Stage;

	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterMm extends SocialNetworkAdapter
	{
		public function AdapterMm(stage:Stage, network:SocialNetwork, errorHandler:IErrorHandler, params:Object)
		{
			super(stage, errorHandler, network, params, LogManager.getByClass(AdapterMm));
		}
	}
}
