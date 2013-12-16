<?php
namespace org\shypl\sna;

use InvalidArgumentException;

abstract class SocialNetworkAdapter
{
	/**
	 * @param string $name
	 *
	 * @return bool
	 */
	static public function exists($name)
	{
		switch (strtolower($name)) {
			case AdapterVk::NAME:
			case AdapterMm::NAME:
			case AdapterOk::NAME:
				return true;
		}

		return false;
	}

	/**
	 * @param string $name
	 * @param array  $params
	 *
	 * @throws \InvalidArgumentException
	 * @return SocialNetworkAdapter
	 */
	static public function factory($name, array $params)
	{
		switch (strtolower($name)) {
			case AdapterVk::NAME:
				return new AdapterVk($params);
			case AdapterMm::NAME:
				return new AdapterMm($params);
			case AdapterOk::NAME:
				return new AdapterOk($params);
		}

		throw new InvalidArgumentException('Undefined social network (' . $name . ')');
	}

	/**
	 * @var int
	 */
	private $id;

	/**
	 * @var string
	 */
	private $name;

	/**
	 * @var string
	 */
	private $signatureSalt;

	/**
	 * @param int    $id
	 * @param string $name
	 * @param string $signatureSalt
	 */
	protected function __construct($id, $name, $signatureSalt)
	{
		$this->id = $id;
		$this->name = $name;
		$this->signatureSalt = $signatureSalt;
	}

	/**
	 * @return int
	 */
	public function id()
	{
		return $this->id;
	}

	/**
	 * @return string
	 */
	public function name()
	{
		return $this->name;
	}

	public function createRequestWrap(array $requestParams)
	{
		return new RequestWrap($this, $requestParams);
	}

	/**
	 * @param string $method
	 * @param array  $params
	 *
	 * @return mixed
	 */
	public function callApi($method, array $params = array())
	{
		return $this->receiveApiResponse($this->requestApi($method, $params));
	}

	/**
	 * @param array $requestParams
	 *
	 * @return bool
	 */
	public abstract function authRequest(array $requestParams);

	/**
	 * @param array $requestParams
	 *
	 * @return bool
	 */
	public abstract function validateRequest(array $requestParams);

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	public abstract function defineRequestUserId(array $requestParams);

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	public function defineFlashParams(array $requestParams)
	{
		return $this->name . ';'
			. 'uid=' . $this->defineRequestUserId($requestParams) . ';'
			. $this->doDefineFlashParams($requestParams);
	}

	/**
	 * @param array $params
	 *
	 * @return string
	 */
	protected function obtainSignature(array $params)
	{
		ksort($params);

		$query = '';
		foreach ($params as $key => $value) {
			$query .= $key . '=' . $value;
		}

		return md5($query . $this->signatureSalt);
	}

	/**
	 * @param string $url
	 * @param array  $params
	 *
	 * @return string
	 */
	protected function sendPostRequest($url, array $params)
	{
		$context = stream_context_create(array('http' => array(
			'method'        => 'POST',
			'timeout'       => 30,
			'ignore_errors' => true,
			'header'        => 'Content-type: application/x-www-form-urlencoded',
			'content'       => http_build_query($params)
		)));

		return file_get_contents($url, false, $context);
	}

	/**
	 * @param string $method
	 * @param array  $params
	 *
	 * @return string
	 */
	protected abstract function requestApi($method, array $params);

	/**
	 * @param string $data
	 *
	 * @return mixed
	 */
	protected abstract function receiveApiResponse($data);

	/**
	 * @param array $requestParams
	 *
	 * @return string
	 */
	protected abstract function doDefineFlashParams(array $requestParams);
}