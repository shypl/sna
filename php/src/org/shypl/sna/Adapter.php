<?php
namespace org\shypl\sna;

use org\shypl\common\net\HttpRequest;

abstract class Adapter {
	private $networkId;
	private $apiUrl;

	/**
	 * @param int    $networkId
	 * @param string $apiUrl
	 */
	public function __construct($networkId, $apiUrl) {
		$this->networkId = $networkId;
		$this->apiUrl = $apiUrl;
	}

	/**
	 * @return int
	 */
	public function getNetworkId() {
		return $this->networkId;
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return mixed
	 */
	public function callApi($method, array $parameters = []) {
		$parameters = $this->defineApiRequestParameters($method, $parameters);

		$context = stream_context_create(['http' => [
			'method' => 'POST',
			'timeout' => 30,
			'ignore_errors' => true,
			'header' => 'Content-type: application/x-www-form-urlencoded',
			'content' => http_build_query($parameters)
		]]);

		$response = file_get_contents($this->apiUrl, null, $context);

		return $this->processApiResponse($response);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return UserSession
	 */
	public function authorizeRequest(HttpRequest $request) {
		if ($this->validateUserSessionRequest($request)) {
			return $this->createUserSession($request);
		}
		return null;
	}

	/**
	 * @param PaymentProcessorDelegate $delegate
	 *
	 * @return PaymentProcessor
	 */
	public abstract function createPaymentProcessor(PaymentProcessorDelegate $delegate);

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public abstract function validateRequest(HttpRequest $request);

	/**
	 * @param HttpRequest $request
	 *
	 * @return UserSession
	 */
	protected function createUserSession(HttpRequest $request) {
		return new UserSession($this->getUserIdFromRequest($request), $this->defineFlashAdapterParameters($request));
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return array
	 */
	protected function defineFlashAdapterParameters(HttpRequest $request) {
		return [
			'aid' => $this->networkId,
			'uid' => $this->getUserIdFromRequest($request)
		];
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return array
	 */
	protected abstract function defineApiRequestParameters($method, array $parameters);

	/**
	 * @param string $data
	 *
	 * @return mixed
	 */
	protected abstract function processApiResponse($data);

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	protected abstract function validateUserSessionRequest(HttpRequest $request);

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected abstract function getUserIdFromRequest(HttpRequest $request);
}