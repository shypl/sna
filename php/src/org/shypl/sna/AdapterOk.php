<?php
namespace org\shypl\sna;

class AdapterOk extends SocialNetworkAdapter
{
	const ID = 3;

	const NAME = "ok";

	/**
	 * @var string
	 */
	private $applicationKey;

	/**
	 * @var string
	 */
	private $secretKey;

	/**
	 * @param array $params
	 */
	public function __construct(array $params)
	{
		parent::__construct(self::ID, self::NAME, $params['secretKey']);

		$this->applicationKey = $params['applicationKey'];
		$this->secretKey = $params['secretKey'];
	}

	/**
	 * @param array $requestParams
	 *
	 * @return bool
	 */
	public function validateRequest(array $requestParams)
	{
		if (!isset($requestParams['sig'])) {
			return false;
		}

		$sig = $requestParams['sig'];
		unset($requestParams['sig']);

		return $sig === $this->obtainSignature($requestParams);
	}

	/**
	 * @param array $requestParams
	 *
	 * @return bool
	 */
	public function authRequest(array $requestParams)
	{
		return isset($requestParams['auth_sig'])
		&& isset($requestParams['logged_user_id'])
		&& isset($requestParams['session_key'])
		&& $requestParams['auth_sig'] === md5($requestParams['logged_user_id'] . $requestParams['session_key'] . $this->secretKey);
	}

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	public function defineRequestUserId(array $requestParams)
	{
		return $requestParams['logged_user_id'];
	}

	/**
	 * @param string $method
	 * @param array  $params
	 *
	 * @return string
	 */
	protected function requestApi($method, array $params)
	{
		$params['method'] = $method;
		$params['application_key'] = $this->applicationKey;
		$params['format'] = 'JSON';
		$params['sig'] = $this->obtainSignature($params);

		return $this->sendPostRequest('http://api.odnoklassniki.ru/fb.do', $params);
	}

	/**
	 * @param string $data
	 *
	 * @return mixed
	 */
	protected function receiveApiResponse($data)
	{
		$data = json_decode($data, true);
		if (is_array($data)) {
			if (isset($data['error_code'])) {
				throw new ApiErrorException($data['error_msg'], $data['error_code']);
			}
			return $data;
		}
		throw new ApiErrorException('Bad api response: ' . json_encode($data));
	}

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	protected function doDefineFlashParams(array $requestParams)
	{
		throw new \RuntimeException("TODO");
	}
}