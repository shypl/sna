<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\sna\AdapterWithSignedApi;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentProcessorDelegate;

class VkAdapter extends AdapterWithSignedApi {
	private $apiId;
	private $secretKey;
	private $testMode;

	/**
	 * @param array $parameters [apiId, secretKey, testMode]
	 */
	public function __construct(array $parameters) {
		parent::__construct(1, 'http://api.vk.com/api.php', $parameters['secretKey']);

		$this->apiId = $parameters['apiId'];
		$this->secretKey = $parameters['secretKey'];
		$this->testMode = isset($parameters['testMode']) ? (bool)$parameters['testMode'] : false;
	}

	/**
	 * @param PaymentProcessorDelegate $delegate
	 *
	 * @return PaymentProcessor
	 */
	public function createPaymentProcessor(PaymentProcessorDelegate $delegate) {
		return new VkPaymentProcessor($this, $delegate);
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return array
	 */
	protected function defineApiRequestParameters($method, array $parameters) {
		$parameters['method'] = $method;
		$parameters['api_id'] = $this->apiId;
		$parameters['format'] = 'JSON';
		$parameters['v'] = '3.0';

		if ($this->testMode) {
			$params['test_mode'] = 1;
		}

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
				throw new ApiErrorException($data['error']['error_msg'] . ' [' . $data['error']['error_code'] . ']', $data['error']['request_params']);
			}

			if (isset($data['response'])) {
				return $data['response'];
			}
		}

		throw new ApiErrorException('Bad api response', $data);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	protected function validateUserSessionRequest(HttpRequest $request) {
		return $request->hasParameter('auth_key') && $request->hasParameter('viewer_id')
		&& ($request->getParameter('auth_key') === md5($this->apiId . '_' . $request->getParameter('viewer_id') . '_' . $this->secretKey));
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function getUserIdFromRequest(HttpRequest $request) {
		return $request->getParameter('viewer_id');
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return array
	 */
	protected function defineFlashAdapterParameters(HttpRequest $request) {
		$parameters = parent::defineFlashAdapterParameters($request);
//		$parameters['acn'] = $request->getParameter('lc_name');
		$parameters['tm'] = $this->testMode;
		return $parameters;
	}
}