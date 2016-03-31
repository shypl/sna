package org.shypl.sna;

import org.shypl.sna.impl.MmSocialNetwork;
import org.shypl.sna.impl.OkSocialNetwork;
import org.shypl.sna.impl.VkSocialNetwork;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.NoSuchElementException;
import java.util.Set;

public final class SocialNetworkManager {
	private static Set<SocialNetwork> networks = new HashSet<>();

	static {
		registerNetwork(new VkSocialNetwork());
		registerNetwork(new MmSocialNetwork());
		registerNetwork(new OkSocialNetwork());
	}

	public static void registerNetwork(SocialNetwork network) {
		networks.add(network);
	}

	public static int countNetworks() {
		return networks.size();
	}

	public static Collection<SocialNetwork> getNetworks() {
		return Collections.unmodifiableCollection(networks);
	}

	public static SocialNetwork getNetwork(int id) {
		for (SocialNetwork network : networks) {
			if (network.getId() == id) {
				return network;
			}
		}
		throw new NoSuchElementException("Network by id " + id + " is not registered");
	}

	public static SocialNetwork getNetwork(String name) {
		for (SocialNetwork network : networks) {
			if (network.getName().equals(name)) {
				return network;
			}
		}
		throw new NoSuchElementException("Network by name " + name + " is not registered");
	}
}
