<?php
namespace org\shypl\sna;

use InvalidArgumentException;
use org\shypl\sna\impl\MmAdapter;
use org\shypl\sna\impl\OkAdapter;
use org\shypl\sna\impl\VkAdapter;

final class AdapterManager {
	/**
	 * @param string $networkName
	 * @param array  $parameters

	 *
*@return Adapter
	 */
	public static function factory($networkName, array $parameters) {
		switch ($networkName) {
			case 'vk':
				return new VkAdapter($parameters);
			case 'mm':
				return new MmAdapter($parameters);
			case 'ok':
				return new OkAdapter($parameters);
			default:
				throw new InvalidArgumentException('Undefined network name ' . $networkName);
		}
	}
}