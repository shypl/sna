<?php

namespace org\shypl\sna\impl;

use Exception;
use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class DevSocialNetwork extends SocialNetwork {

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(0, "dev");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		throw new Exception("Not supported");
	}
}