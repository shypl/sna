package org.shypl.sna;

import org.shypl.sna.impl.DevSocialNetwork;
import org.shypl.sna.impl.MmSocialNetwork;
import org.shypl.sna.impl.OkSocialNetwork;
import org.shypl.sna.impl.VkSocialNetwork;

import java.util.HashSet;
import java.util.NoSuchElementException;
import java.util.Set;

public final class SocialNetworkManager {
	private static Set<SocialNetwork> networks = new HashSet<>();

	static {
		registerNetwork(new DevSocialNetwork());
		registerNetwork(new VkSocialNetwork());
		registerNetwork(new MmSocialNetwork());
		registerNetwork(new OkSocialNetwork());
	}

	public static void registerNetwork(SocialNetwork network) {
		networks.add(network);
	}

	public static SocialNetwork[] getNetworks() {
		return networks.toArray(new SocialNetwork[networks.size()]);
	}

	public static SocialNetwork getNetworkById(int id) {
		for (SocialNetwork network : networks) {
			if (network.getId() == id) {
				return network;
			}
		}
		throw new NoSuchElementException("Network by id " + id + " is not registered");
	}

	public static SocialNetwork getNetworkByName(String name) {
		for (SocialNetwork network : networks) {
			if (network.getName().equals(name)) {
				return network;
			}
		}
		throw new NoSuchElementException("Network by name " + name + " is not registered");
	}
}
