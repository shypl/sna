<?php
namespace org\shypl\sna;

interface PaymentProcessorDelegate {

	/**
	 * @param SocialNetwork $socialNetwork
	 * @param string        $productId
	 * @param string        $userId
	 *
	 * @return PaymentProduct
	 */
	public function getPaymentProduct(SocialNetwork $socialNetwork, $productId, $userId);

	/**
	 * @param PaymentProduct $product
	 *
	 * @return string
	 */
	public function buyPaymentProduct(PaymentProduct $product);

	/**
	 * @param PaymentException $error
	 */
	public function handlePaymentError(PaymentException $error);
}