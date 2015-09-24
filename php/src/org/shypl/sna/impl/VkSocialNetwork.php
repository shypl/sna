<?php

namespace org\shypl\sna\impl;

use org\shypl\sna\Adapter;
use org\shypl\sna\SocialNetwork;

final class VkSocialNetwork extends SocialNetwork {

	/**
	 *
	 */
	public function __construct() {
		parent::__construct(1, "vk");
	}

	/**
	 * @param array $parameters
	 *
	 * @return Adapter
	 */
	public function createAdapter(array $parameters) {
		return new VkAdapter($this, $parameters);
	}}