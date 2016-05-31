package org.shypl.sna;

public abstract class SocialNetwork {
	private final int    id;
	private final String code;
	private final String name;

	public SocialNetwork(int id, String code, String name) {
		this.id = id;
		this.code = code;
		this.name = name;
	}

	public int getId() {
		return id;
	}

	public String getCode() {
		return code;
	}

	public String getName() {
		return name;
	}

	@Override
	public String toString() {
		return code;
	}

	@Override
	public boolean equals(Object obj) {
		return obj == this || obj instanceof SocialNetwork && ((SocialNetwork)obj).id == id;
	}
}
