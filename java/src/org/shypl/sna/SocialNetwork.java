package org.shypl.sna;

public class SocialNetwork
{
	private static final SocialNetwork[] list = new SocialNetwork[]{
		new SocialNetwork(1, "vk"),
		new SocialNetwork(2, "mm"),
		new SocialNetwork(3, "ok"),
	};

	public static SocialNetwork[] list()
	{
		return list.clone();
	}

	public static SocialNetwork get(String code)
	{
		code = code.toLowerCase();

		for (SocialNetwork network : list) {
			if (network.code.equals(code)) {
				return network;
			}
		}

		return null;
	}

	public static SocialNetwork get(int id)
	{
		return list[id - 1];
	}

	public final int    id;
	public final String code;
	public final int    index;

	private SocialNetwork(final int id, final String code)
	{
		this.id = id;
		this.code = code;
		index = id - 1;
	}
}
