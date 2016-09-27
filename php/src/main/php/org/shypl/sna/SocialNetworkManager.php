<?php
namespace org\shypl\sna;

use InvalidArgumentException;
use org\shypl\sna\impl\MmSocialNetwork;
use org\shypl\sna\impl\OkSocialNetwork;
use org\shypl\sna\impl\VkSocialNetwork;

final class SocialNetworkManager {
	/**
	 * @var SocialNetwork[]
	 */
	private static $networks = array();

	/**
	 * @param SocialNetwork $network
	 */
	public static function registerNetwork(SocialNetwork $network) {
		self::$networks[] = $network;
	}

	/**
	 * @param int $id
	 *
	 * @return SocialNetwork
	 */
	public static function getNetworkById($id) {
		foreach (self::$networks as $network) {
			if ($network->getId() == $id) {
				return $network;
			}
		}
		throw new InvalidArgumentException('Network by id ' . $id . ' is not registered');
	}

	/**
	 * @param string $name
	 *
	 * @return SocialNetwork
	 */
	public static function getNetworkByName($name) {
		foreach (self::$networks as $network) {
			if ($network->getName() == $name) {
				return $network;
			}
		}
		throw new InvalidArgumentException('Network by name ' . $name . ' is not registered');
	}
}

SocialNetworkManager::registerNetwork(new VkSocialNetwork());
SocialNetworkManager::registerNetwork(new MmSocialNetwork());
SocialNetworkManager::registerNetwork(new OkSocialNetwork());