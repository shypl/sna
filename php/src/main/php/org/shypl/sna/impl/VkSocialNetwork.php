<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class VkSocialNetwork extends SocialNetwork {
	const ID = 1;

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(self::ID, "vk");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		return new VkAdapter($parameters);
	}
}