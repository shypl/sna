package org.shypl.sna {
	public final class SocialNetworkManager {

		public static const VK:SocialNetwork = new NetworkVk();
		public static const MM:SocialNetwork = new NetworkMm();
		public static const OK:SocialNetwork = new NetworkOk();

		private static const _list:Vector.<SocialNetwork> = new <SocialNetwork>[VK, MM, OK];

		{
			_list.fixed = true;
		}

		public static function getById(id:int):SocialNetwork {
			for each (var network:SocialNetwork in _list) {
				if (network.id == id) {
					return network;
				}
			}
			return null
		}

		public static function getByCode(code:String):SocialNetwork {
			for each (var network:SocialNetwork in _list) {
				if (network.code == code) {
					return network;
				}
			}
			return null
		}

	}
}
