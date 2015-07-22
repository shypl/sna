<?php

namespace org\shypl\sna;

use org\shypl\common\net\HttpRequest;

abstract class AdapterWithSignedApi extends Adapter {
	private $signatureSalt;
	private $signatureName;

	/**
	 * @param int    $networkId
	 * @param string $apiUrl
	 * @param string $signatureName
	 * @param string $signatureSalt
	 */
	public function __construct($networkId, $apiUrl, $signatureSalt, $signatureName = 'sig') {
		parent::__construct($networkId, $apiUrl);
		$this->signatureSalt = $signatureSalt;
		$this->signatureName = $signatureName;
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function validateRequest(HttpRequest $request) {
		if ($request->hasParameter($this->signatureName)) {
			$params = $request->getParameters();
			$sig = $params[$this->signatureName];
			unset($params[$this->signatureName]);

			return $sig === $this->calculateSignature($params);
		}
		return false;
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return array
	 */
	protected function defineApiRequestParameters($method, array $parameters) {
		$parameters[$this->signatureName] = $this->calculateSignature($parameters);
		return $parameters;
	}

	/**
	 * @param array $parameters
	 *
	 * @return string
	 */
	protected function calculateSignature(array $parameters) {
		ksort($parameters);

		$query = '';
		foreach ($parameters as $key => $value) {
			$query .= $key . '=' . $value;
		}

		return md5($query . $this->signatureSalt);
	}
}