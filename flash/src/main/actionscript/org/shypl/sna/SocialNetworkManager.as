package org.shypl.sna {
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import org.shypl.sna.impl.FakeAdapter;
	import org.shypl.sna.impl.FbSocialNetwork;
	import org.shypl.sna.impl.MmSocialNetwork;
	import org.shypl.sna.impl.OkSocialNetwork;
	import org.shypl.sna.impl.VkSocialNetwork;
	
	import ru.capjack.flacy.core.collections.NoSuchElementException;
	import ru.capjack.flacy.core.errors.RuntimeException;
	
	public final class SocialNetworkManager {
		private static const _networks:Vector.<SocialNetwork> = new Vector.<SocialNetwork>();
		
		{
			registerNetwork(new VkSocialNetwork());
			registerNetwork(new MmSocialNetwork());
			registerNetwork(new OkSocialNetwork());
			registerNetwork(new FbSocialNetwork());
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
		
		public static function createAdapterByEnvironment(receiver:SocialNetworkAdapterReceiver, stage:Stage):void {
			if (ExternalInterface.available) {
				var parameters:Object = ExternalInterface.call("__sna_fap");
				if (parameters == null || !parameters.nid) {
					throw new RuntimeException("Incorrect data for social networks");
				}
				getNetworkById(parameters.nid).createAdapter(receiver, stage, parameters);
			}
			else {
				receiver.receiveSocialNetworkAdapter(new FakeAdapter());
			}
		}
	}
}
