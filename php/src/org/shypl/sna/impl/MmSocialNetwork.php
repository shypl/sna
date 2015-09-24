<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class MmSocialNetwork extends SocialNetwork {

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(2, "mm");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		return new MmAdapter($parameters);
	}
}