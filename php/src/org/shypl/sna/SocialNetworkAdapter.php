<?php
namespace org\shypl\sna;

use InvalidArgumentException;
use org\shypl\common\app\HttpRequest;
use org\shypl\common\app\HttpResponse;

abstract class SocialNetworkAdapter {
	/**
	 * @param string $name
	 *
	 * @return bool
	 */
	static public function exists($name) {
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
	static public function factory($name, array $params) {
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
	 * @var int
	 */
	private $index;
	/**
	 * @var string
	 */
	private $signatureSalt;

	/**
	 * @param int    $id
	 * @param string $name
	 * @param string $signatureSalt
	 */
	protected function __construct($id, $name, $signatureSalt) {
		$this->id = $id;
		$this->name = $name;
		$this->index = $id - 1;
		$this->signatureSalt = $signatureSalt;
	}

	/**
	 * @return int
	 */
	public function id() {
		return $this->id;
	}

	/**
	 * @return string
	 */
	public function name() {
		return $this->name;
	}

	/**
	 * @return int
	 */
	public function index() {
		return $this->index;
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return RequestWrap
	 */
	public function createRequestWrap(HttpRequest $request) {
		return new RequestWrap($this, $request);
	}

	/**
	 * @param string $method
	 * @param array  $params
	 *
	 * @return mixed
	 */
	public function callApi($method, array $params = array()) {
		return $this->receiveApiResponse($this->requestApi($method, $params));
	}

	/**
	 * @param string $data
	 *
	 * @return mixed
	 */
	protected abstract function receiveApiResponse($data);

	/**
	 * @param string $method
	 * @param array  $params
	 *
	 * @return string
	 */
	protected abstract function requestApi($method, array $params);

	/**
	 * @param HttpRequest            $request
	 * @param IPaymentRequestHandler $handler
	 *
	 * @return HttpResponse
	 */
	public function processPaymentRequest(HttpRequest $request, IPaymentRequestHandler $handler) {
		try {

			if (!$this->validateRequest($request)) {
				throw new PaymentRequestException(PaymentRequestException::BAD_SIGNATURE);
			}

			return $this->processPaymentRequest0($request, $handler);
		}
		catch (\Exception $e) {

			if (!($e instanceof PaymentRequestException)) {
				$e = new PaymentRequestException(PaymentRequestException::SERVER_ERROR, $e);
			}

			throw $e;
		}
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public abstract function validateRequest(HttpRequest $request);

	/**
	 * @param HttpRequest            $request
	 * @param IPaymentRequestHandler $handler
	 *
	 * @return HttpResponse
	 */
	protected abstract function processPaymentRequest0(HttpRequest $request, IPaymentRequestHandler $handler);

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	public function defineFlashParams(HttpRequest $request) {
		return $this->name . ';'
		. 'u=' . $this->defineRequestUserId($request) . ';'
		. $this->defineFlashParams0($request);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	public abstract function defineRequestUserId(HttpRequest $request);

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected abstract function defineFlashParams0(HttpRequest $request);

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public abstract function authRequest(HttpRequest $request);

	/**
	 * @param PaymentRequestException $e
	 *
	 * @return HttpResponse
	 */
	public abstract function createPaymentRequestErrorResponse(PaymentRequestException $e);

	/**
	 * @param array $params
	 *
	 * @return string
	 */
	protected function obtainSignature(array $params) {
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
	protected function sendPostRequest($url, array $params) {
		$context = stream_context_create(array('http' => array(
			'method'        => 'POST',
			'timeout'       => 30,
			'ignore_errors' => true,
			'header'        => 'Content-type: application/x-www-form-urlencoded',
			'content'       => http_build_query($params)
		)));

		return file_get_contents($url, false, $context);
	}
}