<?php
namespace org\shypl\sna;

use Exception;
use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;

abstract class PaymentProcessor {
	private $adapter;
	private $delegate;

	/**
	 * @param Adapter                  $adapter
	 * @param PaymentProcessorDelegate $delegate
	 */
	public function __construct(Adapter $adapter, PaymentProcessorDelegate $delegate) {
		$this->adapter = $adapter;
		$this->delegate = $delegate;
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return HttpResponse
	 */
	public function process(HttpRequest $request) {
		try {

			if (!$this->adapter->validateRequest($request)) {
				throw new PaymentException(PaymentException::INVALID_REQUEST);
			}

			return $this->doProcess($request);
		}
		catch (Exception $e) {
			if (!($e instanceof PaymentException)) {
				$e = new PaymentException(PaymentException::SERVER_ERROR, $e);
			}

			$this->delegate->handlePaymentError($e);

			return $this->createResponseError($e);
		}
	}

	/**
	 * @param HttpRequest $httpRequest
	 *
	 * @return HttpResponse
	 */
	protected function doProcess(HttpRequest $httpRequest) {
		$paymentRequest = $this->createRequest($httpRequest);
		$product = $this->getProduct($paymentRequest->getProductId(), $paymentRequest->getUserId());

		if ($product->getPrice() !== $paymentRequest->getProductPrice()) {
			throw new PaymentException(PaymentException::PRODUCT_NOT_FOUND);
		}

		$orderId = $this->delegate->buyPaymentProduct($product);

		return $this->createResponseSuccess($paymentRequest, $orderId);
	}

	/**
	 * @param string $productId
	 * @param string $userId
	 *
	 * @return PaymentProduct
	 */
	protected function getProduct($productId, $userId) {
		return $this->delegate->getPaymentProduct($productId, $userId);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	protected abstract function createRequest(HttpRequest $request);

	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	protected abstract function createResponseSuccess(PaymentRequest $request, $orderId);

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	protected abstract function createResponseError(PaymentException $error);
}