<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;
use org\shypl\sna\PaymentException;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentRequest;

class VkPaymentProcessor extends PaymentProcessor {
	/**
	 * @param HttpRequest $httpRequest
	 *
	 * @return HttpResponse
	 */
	protected function doProcess(HttpRequest $httpRequest) {
		$paymentRequest = $this->createPaymentRequest($httpRequest);

		switch ($httpRequest->getParameter('notification_type')) {
			case 'get_item':
			case 'get_item_test':
				$product = $this->delegate->getPaymentProduct($paymentRequest);
				$response = [
					'item_id' => $product->getId(),
					'title' => $product->getName(),
					'price' => $product->getPrice()
				];

				if ($product->hasImage()) {
					$response['photo_url'] = $product->getImage();
				}

				if ($product->hasExpiration()) {
					$response['expiration'] = $product->getExpiration();
				}

				return HttpResponse::factory(HttpResponse::TYPE_JSON, ['response' => $response]);

			case 'order_status_change':
			case 'order_status_change_test':
				if ($httpRequest->getParameter('status') !== 'chargeable') {
					throw new PaymentException(PaymentException::BAD_REQUEST_PARAMETERS);
				}
				return parent::doProcess($httpRequest);

			default:
				throw new PaymentException(PaymentException::BAD_REQUEST_PARAMETERS);
		}
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	public function createPaymentRequest(HttpRequest $request) {
		return new PaymentRequest(
			VkSocialNetwork::ID,
			$request->getParameter('order_id'),
			$request->getParameter('user_id'),
			$request->getParameter('item'),
			$request->getParameter('item_price')
		);
	}

	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseSuccess(PaymentRequest $request, $orderId) {
		return HttpResponse::factory(HttpResponse::TYPE_JSON, ['response' => ['order_id' => $request->getOrderId(), 'app_order_id' => $orderId]]);
	}

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseError(PaymentException $error) {
		static $codes = [
			PaymentException::INVALID_REQUEST => 10,
			PaymentException::BAD_REQUEST_PARAMETERS => 11,
			PaymentException::USER_NOT_FOUND => 22,
			PaymentException::PRODUCT_NOT_FOUND => 20,
			PaymentException::SERVER_UNAVAILABLE => 100,
			PaymentException::SERVER_ERROR => 101,
		];

		return HttpResponse::factory(HttpResponse::TYPE_JSON, ['error' => [
			'error_code' => $codes[$error->getCode()],
			'error_msg' => $error->getMessage(),
			'critical' => $error->isCritical()
		]]);
	}
}