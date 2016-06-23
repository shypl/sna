package org.shypl.sna;

import org.shypl.common.util.Declination;

import java.io.Serializable;

public class Currency implements Serializable {

	private static final long serialVersionUID = 42;

	private String      name;
	private Declination declination;

	public Currency(String name, Declination declination) {
		this.name = name;
		this.declination = declination;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Declination getDeclination() {
		return declination;
	}

	public void setDeclination(Declination declination) {
		this.declination = declination;
	}
}
