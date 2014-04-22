package org.shypl.sna
{
	import flash.display.Stage;

	import org.shypl.common.logging.LogManager;
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterMm extends SocialNetworkAdapter
	{
		public function AdapterMm(stage:Stage, errorHandler:IErrorHandler, params:Object)
		{
			super(stage, errorHandler, SocialNetworkManager.MM, params, LogManager.getByClass(AdapterMm));
		}
	}
}
