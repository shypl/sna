<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\sna\AdapterWithSignedApi;
use org\shypl\sna\PaymentProcessorDelegate;

class OkAdapter extends AdapterWithSignedApi {
	private $applicationKey;
	private $secretKey;

	/**
	 * @param array $parameters
	 */
	public function __construct(array $parameters) {
		parent::__construct(3, 'http://api.odnoklassniki.ru/fb.do', $parameters['secretKey']);

		$this->applicationKey = $parameters['applicationKey'];
		$this->secretKey = $parameters['secretKey'];
	}

	/**
	 * @param PaymentProcessorDelegate $delegate
	 *
	 * @return PaymentProcessor
	 */
	public function createPaymentProcessor(PaymentProcessorDelegate $delegate) {
		return new OkPaymentProcessor($this, $delegate);
	}

	/**
	 * @param string $method
	 * @param array  $parameters
	 *
	 * @return array
	 */
	protected function defineApiRequestParameters($method, array $parameters) {
		$params['method'] = $method;
		$params['application_key'] = $this->applicationKey;
		$params['format'] = 'JSON';
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
			if (isset($data['error_code'])) {
				throw new ApiErrorException($data['error_msg'] . ' [' . $data['error_code'] . ']');
			}
		}
		return $data;
		//throw new ApiErrorException('Bad api response', $data);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	protected function validateUserSessionRequest(HttpRequest $request) {
		return $request->hasParameter('auth_sig') && $request->hasParameter('logged_user_id') && $request->hasParameter('session_key')
		&& ($request->getParameter('auth_sig') === md5($request->getParameter('logged_user_id') . $request->getParameter('session_key') . $this->secretKey));
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function getUserIdFromRequest(HttpRequest $request) {
		return $request->getParameter('logged_user_id');
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return array
	 */
	protected function defineFlashAdapterParameters(HttpRequest $request) {
		$parameters = parent::defineFlashAdapterParameters($request);
//		$parameters['ak'] = $this->applicationKey;
//		$parameters['sk'] = $this->secretKey;
//		$parameters['ac'] = $request->getParameter('apiconnection');
//		$parameters['sek'] = $request->getParameter('session_key');
//		$parameters['ssk'] = $request->getParameter('session_secret_key');
//		$parameters['as'] = $request->getParameter('api_server');
		return $parameters;
	}
}