package org.shypl.sna;

import java.io.Serializable;

public abstract class SocialNetwork implements Comparable<SocialNetwork>, Serializable {
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

	@Override
	public int hashCode() {
		return id;
	}

	@Override
	public int compareTo(SocialNetwork other) {
		return Integer.compare(this.getId(), other.getId());
	}
}
