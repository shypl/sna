<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;
use org\shypl\sna\PaymentException;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentRequest;

class MmPaymentProcessor extends PaymentProcessor {

	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	public function createPaymentRequest(HttpRequest $request) {
		$productPrice = (int)$request->getParameter('mailiki_price');

		if (!$productPrice) {
			$productPrice = (int)((int)$request->getParameter('other_price') / 100);
		}
		if (!$productPrice) {
			$productPrice = (int)((int)$request->getParameter('sms_price') * 30);
		}

		return new PaymentRequest(
			$request->getParameter('transaction_id'),
			$request->getParameter('uid'),
			$request->getParameter('service_id'),
			$productPrice
		);
	}

	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseSuccess(PaymentRequest $request, $orderId) {
		return HttpResponse::factory(HttpResponse::TYPE_JSON, ['status' => 1]);
	}

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseError(PaymentException $error) {
		switch ($error->getCode()) {
			case PaymentException::INVALID_REQUEST:
			case PaymentException::BAD_REQUEST_PARAMETERS:
				$r = ['status' => 2, 'error_code' => 700];
				break;

			case PaymentException::SERVER_ERROR:
			case PaymentException::SERVER_UNAVAILABLE:
				$r = ['status' => 0, 'error_code' => 700];
				break;

			case PaymentException::USER_NOT_FOUND:
				$r = ['status' => 2, 'error_code' => 701];
				break;

			case PaymentException::PRODUCT_NOT_FOUND:
				$r = ['status' => 2, 'error_code' => 702];
				break;

			default:
				$r = ['status' => 2, 'error_code' => 700];
				break;
		}

		return HttpResponse::factory(HttpResponse::TYPE_JSON, $r);
	}
}