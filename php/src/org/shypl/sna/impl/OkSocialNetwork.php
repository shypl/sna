<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class OkSocialNetwork extends SocialNetwork {

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(3, "ok");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		return new OkAdapter($parameters);
	}
}