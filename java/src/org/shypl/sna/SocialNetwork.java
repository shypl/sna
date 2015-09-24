package org.shypl.sna;

public abstract class SocialNetwork {
	private final int    id;
	private final String name;

	public SocialNetwork(int id, String name) {
		this.id = id;
		this.name = name;
	}

	public int getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	@Override
	public String toString() {
		return name ;
	}

	@Override
	public boolean equals(Object obj) {
		return obj == this || obj instanceof SocialNetwork && ((SocialNetwork)obj).id == id;
	}
}
