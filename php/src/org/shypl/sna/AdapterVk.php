<?php
namespace org\shypl\sna;

use org\shypl\app\HttpRequest;
use org\shypl\app\HttpResponse;

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
	 * @param HttpRequest $request
	 *
	 * @return bool
	 */
	public function validateRequest(HttpRequest $request)
	{
		if ($request->hasParam('sig')) {
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
		return $request->hasParam('auth_key')
		&& $request->hasParam('viewer_id')
		&& $request->param('auth_key')
		=== md5($this->apiId . '_' . $request->param('viewer_id') . '_' . $this->secretKey);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	public function defineRequestUserId(HttpRequest $request)
	{
		return $request->param('viewer_id');
	}

	/**
	 * @param PaymentRequestException $e
	 *
	 * @return HttpResponse
	 */
	public function createPaymentRequestErrorResponse(PaymentRequestException $e)
	{
		static $codes
		= array(
			PaymentRequestException::BAD_SIGNATURE     => 10,
			PaymentRequestException::BAD_PARAMS        => 11,
			PaymentRequestException::USER_NOT_FOUND    => 22,
			PaymentRequestException::PRODUCT_NOT_FOUND => 20,
			PaymentRequestException::SERVER_ERROR      => 100,
		);

		return HttpResponse::factory(HttpResponse::TYPE_JSON, array('error' => array(
			'error_code' => $codes[$e->getCode()],
			'error_msg'  => $e->getMessage(),
			'critical'   => $e->critical
		)));
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
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function defineFlashParams0(HttpRequest $request)
	{
		$str = 'acn=' . $request->param('lc_name');

		if ($this->testMode) {
			$str .= ';tm=1';
		}

		return $str;
	}

	/**
	 * @param HttpRequest            $request
	 * @param IPaymentRequestHandler $handler
	 *
	 * @return HttpResponse
	 */
	protected function processPaymentRequest0(HttpRequest $request, IPaymentRequestHandler $handler)
	{
		switch ($request->param('notification_type')) {
			case 'get_item':
			case 'get_item_test':
				$product = $handler->defineProduct($request->param('item'), $request->param('user_id'));
				$response = array(
					'item_id'   => $product->id(),
					'title'     => $product->name(),
					'price'     => $product->price(),
					'photo_url' => $product->img()
				);
				break;

			case 'order_status_change':
			case 'order_status_change_test':

				if ($request->param('status') !== 'chargeable') {
					throw new PaymentRequestException(PaymentRequestException::BAD_PARAMS);
				}

				$paymentRequest = new PaymentRequest(
					$request->param('order_id'),
					$request->param('user_id'),
					$request->param('item_id'),
					$request->param('item_price')
				);

				$product = $handler->defineProduct($paymentRequest->productId(), $paymentRequest->userId());

				if ($product->price() !== $paymentRequest->productPrice()) {
					throw new PaymentRequestException(PaymentRequestException::PRODUCT_NOT_FOUND);
				}

				$paymentId = $handler->buyProduct($product, $paymentRequest);

				$response = array('order_id' => $paymentRequest->orderId(), 'app_order_id' => $paymentId);
				break;

			default:
				throw new PaymentRequestException(PaymentRequestException::BAD_PARAMS);
		}

		return HttpResponse::factory(HttpResponse::TYPE_JSON, array('response' => $response));
	}
}