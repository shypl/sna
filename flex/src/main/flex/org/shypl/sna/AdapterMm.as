package org.shypl.sna
{
	internal class AdapterMm extends SocialNetworkAdapter
	{
		public function AdapterMm(network:Network, params:Object)
		{
			super(network, params.uid, errorHandler);
		}
	}
}
