package org.shypl.sna.impl;

import org.shypl.common.util.DeclinationImpl;
import org.shypl.sna.Currency;
import org.shypl.sna.SocialNetwork;

public final class VkSocialNetwork extends SocialNetwork {
	public VkSocialNetwork() {
		super(1, "vk", "ВКонтакте", new Currency("голоса", new DeclinationImpl("голос", "голоса", "голосов")));
	}
}
