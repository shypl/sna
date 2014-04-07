<?php
namespace org\shypl\sna;

use org\shypl\http\HttpRequest;
use org\shypl\http\HttpResponse;

class AdapterMm extends Adapter
{
	const ID = 2;
	const NAME = "mm";

	/**
	 * @var string
	 */
	private $appId;
	/**
	 * @var string
	 */
	private $secretKey;
	/**
	 * @var string
	 */
	private $privateKey;

	/**
	 * @param array $params
	 */
	public function __construct(array $params)
	{
		parent::__construct(self::ID, self::NAME, $params['secretKey']);

		$this->appId = $params['appId'];
		$this->secretKey = $params['secretKey'];
		$this->privateKey = $params['privateKey'];
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function validateRequest(HttpRequest $request)
	{
		if ($request->containsParam('sig')) {
			$params = $request->params();
			$sig = $params['sig'];
			unset($params['sig']);

			return $sig === $this->obtainSignature($params);
		}

		return false;
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function authRequest(HttpRequest $request)
	{
		return $this->validateRequest($request);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	public function defineRequestUserId(HttpRequest $request)
	{
		return $request->param('vid');
	}

	/**
	 * @param PaymentRequestException $e
	 *
	 * @return HttpResponse
	 */
	public function createPaymentRequestErrorResponse(PaymentRequestException $e)
	{
		switch ($e->getCode()) {
			case PaymentRequestException::BAD_SIGNATURE:
			case PaymentRequestException::BAD_PARAMS:
				$r = array('status' => 2, 'error_code' => 700);
				break;

			case PaymentRequestException::SERVER_ERROR:
				$r = array('status' => 0, 'error_code' => 700);
				break;

			case PaymentRequestException::USER_NOT_FOUND:
				$r = array('status' => 2, 'error_code' => 701);
				break;

			case PaymentRequestException::PRODUCT_NOT_FOUND:
				$r = array('status' => 2, 'error_code' => 702);
				break;

			default:
				$r = array('status' => 2, 'error_code' => 700);
				break;
		}

		return HttpResponse::factoryJson($r);
	}

	/**
	 * @param string $method
	 * @param array $params
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
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function defineFlashParams0(HttpRequest $request)
	{
		return 'pk=' . $this->privateKey;
	}

	/**
	 * @param HttpRequest $request
	 * @param IPaymentRequestHandler $handler
	 *
	 * @return HttpResponse
	 */
	protected function processPaymentRequest0(HttpRequest $request, IPaymentRequestHandler $handler)
	{
		$productPrice = (int)$request->param('mailiki_price');

		if (!$productPrice) {
			$productPrice = (int)($request->param('other_price', 0) / 100);
		}
		if (!$productPrice) {
			$productPrice = (int)($request->param('sms_price', 0) * 30);
		}
		if (!$productPrice) {
			throw new PaymentRequestException(PaymentRequestException::BAD_PARAMS);
		}

		$paymentRequest = new PaymentRequest(
			$request->param('transaction_id'),
			$request->param('uid'),
			$request->param('service_id'),
			$productPrice);

		$product = $handler->defineProduct($paymentRequest->productId(), $paymentRequest->userId());

		if ($product->price() !== $paymentRequest->productPrice()) {
			throw new PaymentRequestException(PaymentRequestException::PRODUCT_NOT_FOUND);
		}

		$handler->buyProduct($product, $paymentRequest);

		return HttpResponse::factoryJson(array('status' => 1));
	}
}