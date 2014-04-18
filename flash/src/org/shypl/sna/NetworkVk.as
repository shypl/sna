package org.shypl.sna
{
	import flash.display.Stage;

	import org.shypl.common.util.IErrorHandler;
	import org.shypl.common.util.StringUtils;

	internal class NetworkVk extends SocialNetwork
	{
		public function NetworkVk()
		{
			super(1, "vk");
		}

		override public function defineCurrencyLabel(number:Number):String
		{
			return StringUtils.defineNumberDeclinationRu(number, "голос", "голоса", "голосов");
		}

		override internal function createAdapter(stage:Stage, errorHandler:IErrorHandler, params:Object):SocialNetworkAdapter
		{
			return new AdapterVk(stage, errorHandler, params);
		}
	}
}
