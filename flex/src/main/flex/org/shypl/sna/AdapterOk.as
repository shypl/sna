package org.shypl.sna
{
	internal class AdapterOk extends SocialNetworkAdapter
	{
		public function AdapterOk(network:Network, params:Object)
		{
			super(network, params.uid, errorHandler);
		}
	}
}
