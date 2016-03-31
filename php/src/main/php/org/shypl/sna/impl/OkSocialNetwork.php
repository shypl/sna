<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class OkSocialNetwork extends SocialNetwork {
	const ID = 3;

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(self::ID, "ok");
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