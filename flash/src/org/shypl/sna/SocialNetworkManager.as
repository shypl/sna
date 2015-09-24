package org.shypl.sna {
	import flash.display.Stage;
	import flash.external.ExternalInterface;

	import org.shypl.common.collection.NoSuchElementException;
	import org.shypl.sna.impl.DevAdapter;
	import org.shypl.sna.impl.DevSocialNetwork;
	import org.shypl.sna.impl.MmSocialNetwork;
	import org.shypl.sna.impl.OkSocialNetwork;
	import org.shypl.sna.impl.VkSocialNetwork;

	public final class SocialNetworkManager {
		private static const _networks:Vector.<SocialNetwork> = new Vector.<SocialNetwork>();

		{
			registerNetwork(new DevSocialNetwork());
			registerNetwork(new VkSocialNetwork());
			registerNetwork(new MmSocialNetwork());
			registerNetwork(new OkSocialNetwork());
		}

		public static function registerNetwork(network:SocialNetwork):void {
			_networks.push(network);
		}

		public static function getNetworkById(id:int):SocialNetwork {
			for each (var network:SocialNetwork in _networks) {
				if (network.id === id) {
					return network;
				}
			}
			throw new NoSuchElementException("Network by id " + id + " is not registered");
		}

		public static function getNetworkByName(name:String):SocialNetwork {
			for each (var network:SocialNetwork in _networks) {
				if (network.name === name) {
					return network;
				}
			}
			throw new NoSuchElementException("Network by name " + name + " is not registered");
		}

		public static function createAdapterByEnvironment(receiver:AdapterReceiver, stage:Stage):void {
			if (ExternalInterface.available) {
				var parameters:Object = ExternalInterface.call("__sna_fap");
				getNetworkById(parameters.nid).createAdapter(receiver, stage, parameters);
			}
			else {
				receiver.receiveAdapter(new DevAdapter('DEV-1'));
			}
		}
	}
}
