<?php
namespace org\shypl\sna;

use Exception;
use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;

abstract class PaymentProcessor {
	private $adapter;
	protected $delegate;

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

			$this->delegate->handlePaymentError($request, $e);

			return $this->createHttpResponseError($e);
		}
	}

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseServerUnavailable() {
		return $this->createHttpResponseError(new PaymentException(PaymentException::SERVER_UNAVAILABLE));
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	public abstract function createPaymentRequest(HttpRequest $request);

	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	public abstract function createHttpResponseSuccess(PaymentRequest $request, $orderId);

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	public abstract function createHttpResponseError(PaymentException $error);

	/**
	 * @param HttpRequest $httpRequest
	 *
	 * @return HttpResponse
	 */
	protected function doProcess(HttpRequest $httpRequest) {
		$paymentRequest = $this->createPaymentRequest($httpRequest);
		$product = $this->delegate->getPaymentProduct($paymentRequest);

		if ($product->getPrice() !== $paymentRequest->getProductPrice()) {
			throw new PaymentException(PaymentException::PRODUCT_NOT_FOUND);
		}

		$orderId = $this->delegate->buyPaymentProduct($paymentRequest, $product);

		return $this->createHttpResponseSuccess($paymentRequest, $orderId);
	}
}