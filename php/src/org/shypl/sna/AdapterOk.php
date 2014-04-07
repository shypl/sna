<?php
namespace org\shypl\sna;

use org\shypl\app\HttpRequest;
use org\shypl\app\HttpResponse;

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
		return $request->hasParam('auth_sig')
		&& $request->hasParam('logged_user_id')
		&& $request->hasParam('session_key')
		&& $request->param('auth_sig')
		=== md5($request->param('logged_user_id') . $request->param('session_key') . $this->secretKey);
	}

	/**
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	public function defineRequestUserId(HttpRequest $request)
	{
		return $request->param('logged_user_id');
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
				$code = 104;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>104</error_code><error_msg>PARAM_SIGNATURE: Invalid signature</error_msg>' .
					'</ns2:error_response>';
				break;

			case PaymentRequestException::SERVER_ERROR:
				$code = 2;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>2</error_code><error_msg>SERVICE: Service temporary unavailable</error_msg>' .
					'</ns2:error_response>';
				break;

			case PaymentRequestException::BAD_PARAMS:
			case PaymentRequestException::USER_NOT_FOUND:
			case PaymentRequestException::PRODUCT_NOT_FOUND:
				$code = 1001;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>1001</error_code><error_msg>CALLBACK_INVALID_PAYMENT: Payment is invalid and can not be processed</error_msg>' .
					'</ns2:error_response>';
				break;

			default:
				$code = 1;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>1</error_code><error_msg>UNKNOWN: Unknown error</error_msg>' .
					'</ns2:error_response>';
				break;
		}

		$response = HttpResponse::factory(HttpResponse::TYPE_XML, $body);
		$response->setHeader('invocation-error', $code);

		return $response;
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
	 * @param HttpRequest $request
	 *
	 * @return string
	 */
	protected function defineFlashParams0(HttpRequest $request)
	{
		return 'ak=' . $this->applicationKey
		. ';sk=' . $this->secretKey
		. ';ac=' . $request->param("apiconnection")
		. ';sek=' . $request->param("session_key")
		. ';sesk=' . $request->param("session_secret_key")
		. ';as=' . $request->param("api_server");
	}

	/**
	 * @param HttpRequest            $request
	 * @param IPaymentRequestHandler $handler
	 *
	 * @return HttpResponse
	 */
	protected function processPaymentRequest0(HttpRequest $request, IPaymentRequestHandler $handler)
	{
		$paymentRequest = new PaymentRequest(
			$request->param('transaction_id'),
			$request->param('uid'),
			$request->param('product_code'),
			(int)$request->param('amount')
		);

		$product = $handler->defineProduct($paymentRequest->productId(), $paymentRequest->userId());

		if ($product->price() !== $paymentRequest->productPrice()) {
			throw new PaymentRequestException(PaymentRequestException::PRODUCT_NOT_FOUND);
		}

		$handler->buyProduct($product, $paymentRequest);

		return HttpResponse::factory(HttpResponse::TYPE_XML,
			'<?xml version="1.0" encoding="UTF-8"?><callbacks_payment_response xmlns="http://api.forticom.com/1.0/">true</callbacks_payment_response>');
	}
}