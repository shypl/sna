<?php
namespace org\shypl\sna;

use org\shypl\http\HttpRequest;

class RequestAdapterWrap
{
	/**
	 * @var Adapter
	 */
	private $adapter;

	/**
	 * @var HttpRequest
	 */
	private $params;

	/**
	 * @param Adapter $adapter
	 * @param HttpRequest          $params
	 */
	public function __construct(Adapter $adapter, HttpRequest $params)
	{
		$this->adapter = $adapter;
		$this->params = $params;
	}

	/**
	 * @return bool
	 */
	public function auth()
	{
		return $this->adapter->authRequest($this->params);
	}

	/**
	 * @return bool
	 */
	public function validate()
	{
		return $this->adapter->validateRequest($this->params);
	}

	/**
	 * @return string
	 */
	public function userId()
	{
		return $this->adapter->defineRequestUserId($this->params);
	}

	/**
	 * @return string
	 */
	public function flashParams()
	{
		return $this->adapter->defineFlashParams($this->params);
	}
}