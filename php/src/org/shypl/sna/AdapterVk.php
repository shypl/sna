<?php
namespace org\shypl\sna;

class AdapterVk extends SocialNetworkAdapter
{
	const ID = 1;

	const NAME = "vk";

	/**
	 * @var string
	 */
	private $apiId;

	/**
	 * @var string
	 */
	private $secretKey;

	/**
	 * @var bool
	 */
	private $testMode;

	/**
	 * @param array $params
	 */
	public function __construct(array $params)
	{
		parent::__construct(self::ID, self::NAME, $params['secretKey']);

		$this->apiId = $params['apiId'];
		$this->secretKey = $params['secretKey'];
		$this->testMode = isset($params['testMode']) ? $params['testMode'] : false;
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
		return isset($requestParams['auth_key'])
		&& isset($requestParams['viewer_id'])
		&& $requestParams['auth_key'] === md5($this->apiId . '_' . $requestParams['viewer_id'] . '_' . $this->secretKey);
	}

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	public function defineRequestUserId(array $requestParams)
	{
		return $requestParams['viewer_id'];
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
		$params['api_id'] = $this->apiId;
		$params['format'] = 'JSON';
		$params['v'] = '3.0';

		if ($this->testMode) {
			$params['test_mode'] = 1;
		}

		$params['sig'] = $this->obtainSignature($params);

		return $this->sendPostRequest('http://api.vk.com/api.php', $params);
	}

	/**
	 * @param string $data
	 *
	 * @return array
	 */
	protected function receiveApiResponse($data)
	{
		$data = json_decode($data, true);

		if (is_array($data)) {
			if (isset($data['error'])) {
				throw new ApiErrorException($data['error']['error_msg'], $data['error']['error_code']);
			}

			if (isset($data['response'])) {
				return $data['response'];
			}
		}

		throw new ApiErrorException('Bad api response: ' . json_encode($data) . '');
	}

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	protected function doDefineFlashParams(array $requestParams)
	{
		$str = 'acn=' . $requestParams['lc_name'];

		if ($this->testMode) {
			$str .= ';tm=1';
		}

		return $str;
	}
}