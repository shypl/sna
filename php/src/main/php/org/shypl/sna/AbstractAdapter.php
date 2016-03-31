<?php

namespace org\shypl\sna;

use org\shypl\common\net\HttpRequest;

abstract class AbstractAdapter implements Adapter {
	private $network;
	private $apiUrl;

	/**
	 * @param int    $networkId
	 * @param string $apiUrl
	 */
	public function __construct($networkId, $apiUrl) {
		$this->network = SocialNetworkManager::getNetworkById($networkId);
		$this->apiUrl = $apiUrl;
	}

	/**
	 * @return SocialNetwork
	 */
	public function getNetwork() {
		return $this->network;
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
			'nid' => $this->network->getId(),
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