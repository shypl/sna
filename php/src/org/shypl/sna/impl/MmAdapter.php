<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\sna\AdapterWithSignedApi;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentProcessorDelegate;

class MmAdapter extends AdapterWithSignedApi {
	private $appId;
	private $secretKey;
	private $privateKey;

	/**
	 * @param array $parameters
	 */
	public function __construct(array $parameters) {
		parent::__construct(2, 'http://appsmail.ru/platform/api', $parameters['secretKey']);

		$this->appId = $parameters['appId'];
		$this->secretKey = $parameters['secretKey'];
		$this->privateKey = $parameters['privateKey'];
	}

	/**
	 * @param PaymentProcessorDelegate $delegate
	 *
	 * @return PaymentProcessor
	 */
	public function createPaymentProcessor(PaymentProcessorDelegate $delegate) {
		return new MmPaymentProcessor($this, $delegate);
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return array
	 */
	protected function defineApiRequestParameters($method, array $parameters) {
		$parameters['method'] = $method;
		$parameters['app_id'] = $this->appId;
		return parent::defineApiRequestParameters($method, $parameters);
	}

	/**
	 * @param string $data
	 *
	 * @return mixed
	 */
	protected function processApiResponse($data) {
		$data = json_decode($data, true);
		if (is_array($data)) {
			if (isset($data['error'])) {
				throw new ApiErrorException($data['error']['error_msg'] . ' [' . $data['error']['error_code'] . ']');
			}
			return $data;
		}
		throw new ApiErrorException('Bad api response', $data);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	protected function validateUserSessionRequest(HttpRequest $request) {
		return $this->validateRequest($request);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function getUserIdFromRequest(HttpRequest $request) {
		return $request->getParameter('vid');
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return array
	 */
	protected function defineFlashAdapterParameters(HttpRequest $request) {
		$parameters = parent::defineFlashAdapterParameters($request);
		$parameters['pk'] = $this->privateKey;
		return $parameters;
	}
}