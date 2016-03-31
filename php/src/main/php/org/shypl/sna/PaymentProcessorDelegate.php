<?php
namespace org\shypl\sna;

use org\shypl\common\net\HttpRequest;

interface PaymentProcessorDelegate {

	/**
	 * @param PaymentRequest $request
	 *
	 * @return PaymentProduct
	 */
	public function getPaymentProduct(PaymentRequest $request);

	/**
	 * @param PaymentRequest $request
	 * @param PaymentProduct $product
	 *
	 * @return string
	 */
	public function buyPaymentProduct(PaymentRequest $request, PaymentProduct $product);

	/**
	 * @param HttpRequest      $request
	 * @param PaymentException $error
	 */
	public function handlePaymentError(HttpRequest $request, PaymentException $error);
}