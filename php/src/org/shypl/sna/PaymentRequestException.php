<?php
namespace org\shypl\sna;

class PaymentRequestException extends \Exception
{
	const BAD_SIGNATURE = 1;
	const BAD_PARAMS = 2;
	const USER_NOT_FOUND = 3;
	const PRODUCT_NOT_FOUND = 4;
	const SERVER_UNAVAILABLE = 5;
	const SERVER_ERROR = 100;

	/**
	 * @param int        $code
	 * @param \Exception $previous
	 */
	public function __construct($code, \Exception $previous = null)
	{

		switch ($code) {
			case self::BAD_SIGNATURE:
				$message = 'Invalid signature';
				$critical = true;
				break;

			case self::BAD_PARAMS:
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
}