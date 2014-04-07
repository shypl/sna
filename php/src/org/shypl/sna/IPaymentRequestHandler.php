<?php
namespace org\shypl\sna;

interface IPaymentRequestHandler
{
	/**
	 * @param string $productId
	 * @param string $userId
	 *
	 * @return PaymentProduct
	 */
	public function defineProduct($productId, $userId);

	/**
	 * @param PaymentProduct $product
	 * @param PaymentRequest $request
	 *
	 * @return string
	 */
	public function buyProduct(PaymentProduct $product, PaymentRequest $request);
}