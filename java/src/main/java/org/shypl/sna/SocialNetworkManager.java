package org.shypl.sna;

import org.shypl.sna.impl.FbSocialNetwork;
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
		registerNetwork(new FbSocialNetwork());
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

	public static SocialNetwork getNetwork(String code) {
		for (SocialNetwork network : networks) {
			if (network.getCode().equals(code)) {
				return network;
			}
		}
		throw new NoSuchElementException("Network by code \"" + code + "\" is not registered");
	}
}
