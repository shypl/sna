package org.shypl.sna
{
	import org.shypl.common.util.IErrorHandler;

	internal class AdapterOk extends SocialNetworkAdapter
	{
		public function AdapterOk(network:SocialNetwork, errorHandler:IErrorHandler, params:Object)
		{
			super(network, errorHandler, params);
		}
	}
}
