package org.shypl.sna.impl;

import org.shypl.common.util.DeclinationImpl;
import org.shypl.sna.Currency;
import org.shypl.sna.SocialNetwork;

public final class FbSocialNetwork extends SocialNetwork {
	public FbSocialNetwork() {
		super(4, "fb", "Facebook", new Currency("fb_currency", new DeclinationImpl("fb_currency", "fb_currency", "fb_currency")));
	}
}
