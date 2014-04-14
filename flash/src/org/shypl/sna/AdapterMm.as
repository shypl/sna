package org.shypl.sna
{
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterMm extends SocialNetworkAdapter
	{
		public function AdapterMm(network:SocialNetwork, errorHandler:IErrorHandler, params:Object)
		{
			super(network, errorHandler, params);
		}
	}
}
