<?php
namespace org\shypl\sna;

use org\shypl\common\net\HttpRequest;

interface Adapter {
	/**
	 * @return SocialNetwork
	 */
	public function getNetwork();

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return mixed
	 */
	public function callApi($method, array $parameters = []);

	/**
	 * @param HttpRequest $request
	 *
	 * @return UserSession
	 */
	public function authorizeRequest(HttpRequest $request);

	/**
	 * @param PaymentProcessorDelegate $delegate
	 *
	 * @return PaymentProcessor
	 */
	public function createPaymentProcessor(PaymentProcessorDelegate $delegate);

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function validateRequest(HttpRequest $request);
}