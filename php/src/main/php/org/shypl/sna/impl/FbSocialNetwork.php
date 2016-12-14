<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class FbSocialNetwork extends SocialNetwork {
	const ID = 4;

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(self::ID, "fb");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		return new FbAdapter($parameters);
	}
}