package org.shypl.sna.impl;

import org.shypl.common.util.DeclinationImpl;
import org.shypl.sna.Currency;
import org.shypl.sna.SocialNetwork;

public final class MmSocialNetwork extends SocialNetwork {
	public MmSocialNetwork() {
		super(2, "mm", "Мой Мир", new Currency("мэйлики", new DeclinationImpl("мэйлик", "мэйлика", "мэйликов")));
	}
}
