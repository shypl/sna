package org.shypl.sna.impl;

import org.shypl.common.util.DeclinationImpl;
import org.shypl.sna.Currency;
import org.shypl.sna.SocialNetwork;

public final class OkSocialNetwork extends SocialNetwork {
	public OkSocialNetwork() {
		super(3, "ok", "Одноклассники", new Currency("ок", new DeclinationImpl("ок", "ок", "ок")));
	}
}
