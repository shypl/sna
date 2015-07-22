<?php
namespace org\shypl\sna;

use Exception;

class PaymentException extends Exception {
	const INVALID_REQUEST = 1;
	const BAD_REQUEST_PARAMETERS = 2;
	const USER_NOT_FOUND = 3;
	const PRODUCT_NOT_FOUND = 4;
	const SERVER_UNAVAILABLE = 5;
	const SERVER_ERROR = 100;

	private $critical;

	/**
	 * @param int        $code
	 * @param \Exception $previous
	 */
	public function __construct($code, \Exception $previous = null) {

		switch ($code) {
			case self::INVALID_REQUEST:
				$message = 'Invalid request';
				$critical = true;
				break;

			case self::BAD_REQUEST_PARAMETERS:
				$message = 'Request parameters do not meet specifications';
				$critical = true;
				break;

			case self::USER_NOT_FOUND:
				$message = 'User not found';
				$critical = true;
				break;

			case self::PRODUCT_NOT_FOUND:
				$message = 'Product not found';
				$critical = true;
				break;

			case self::SERVER_UNAVAILABLE:
				$message = 'Server unavailable';
				$critical = false;
				break;

			case self::SERVER_ERROR:
			default:
				$message = 'Server error';
				$critical = false;
				break;
		}

		parent::__construct($message, $code, $previous);
		$this->critical = $critical;
	}

	/**
	 * @return boolean
	 */
	public function isCritical() {
		return $this->critical;
	}
}