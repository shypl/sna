<?php
namespace org\shypl\sna;

class AdapterMm extends SocialNetworkAdapter
{
	const ID = 2;

	const NAME = "mm";

	/**
	 * @var string
	 */
	private $appId;

//	/**
//	 * @var string
//	 */
//	private $secretKey;
//
//	/**
//	 * @var string
//	 */
//	private $privateKey;

	/**
	 * @param array $params
	 */
	public function __construct(array $params)
	{
		parent::__construct(self::ID, self::NAME, $params['secretKey']);

		$this->appId = $params['appId'];
//		$this->secretKey = $params['secretKey'];
//		$this->privateKey = $params['privateKey'];
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
		return $this->validateRequest($requestParams);
	}

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	public function defineRequestUserId(array $requestParams)
	{
		return $requestParams['vid'];
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
		$params['app_id'] = $this->appId;
		$params['sig'] = $this->obtainSignature($params);

		return $this->sendPostRequest('http://appsmail.ru/platform/api', $params);
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
			if (isset($data['error'])) {
				throw new ApiErrorException($data['error']['error_msg'], $data['error']['error_code']);
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