<?php

namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\sna\AbstractAdapter;
use org\shypl\sna\ApiException;
use org\shypl\sna\PaymentProcessorDelegate;

class FbAdapter extends AbstractAdapter
{
	private $appId;
	private $secretKey;
	
	public function __construct(array $parameters) {
		parent::__construct(FbSocialNetwork::ID, '');
		
		$this->appId = $parameters['appId'];
		$this->secretKey = $parameters['secretKey'];
	}
	
	public function createPaymentProcessor(PaymentProcessorDelegate $delegate) {
		
	}
	
	protected function defineApiRequestParameters($method, array $parameters) {
		return parent::defineApiRequestParameters($method, $parameters);
	}
	
	protected function processApiResponse($data) {
		throw new ApiException('Bad api response', $data);
	}
	
	protected function validateUserSessionRequest(HttpRequest $request) {
		$data = $this->parseRequest($request);
		
		return isset($data['user_id']);
	}
	
	protected function getUserIdFromRequest(HttpRequest $request) {
		$data = $this->parseRequest($request);
		return $data['user_id'];
	}
	
	protected function defineFlashAdapterParameters(HttpRequest $request) {
		$parameters = parent::defineFlashAdapterParameters($request);
		$parameters['aid'] = $this->appId;
		return $parameters;
	}
	
	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function validateRequest(HttpRequest $request) {
		return $this->parseRequest($request) != null;
	}
	
	private function base64_url_decode($input) {
		return base64_decode(strtr($input, '-_', '+/'));
	}
	
	private function parseRequest(HttpRequest $request) {
		$signedRequest = explode('.', $request->getParameter('signed_request'), 2);
		
		if (!empty($signedRequest) && count($signedRequest) == 2) {
			list($encoded_sig, $payload) = $signedRequest;
			
			$sig = $this->base64_url_decode($encoded_sig);
			$data = json_decode($this->base64_url_decode($payload), true);
			
			$expected_sig = hash_hmac('sha256', $payload, $this->secretKey, true);
			if ($sig !== $expected_sig) {
				return null;
			}
			return $data;
		}
		
		return null;
	}
}