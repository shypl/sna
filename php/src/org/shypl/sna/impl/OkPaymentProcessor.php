<?php
namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;
use org\shypl\sna\PaymentException;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentRequest;

class OkPaymentProcessor extends PaymentProcessor {

	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	public function createPaymentRequest(HttpRequest $request) {
		return new PaymentRequest(
			$request->getParameter('transaction_id'),
			$request->getParameter('uid'),
			$request->getParameter('product_code'),
			(int)$request->getParameter('amount')
		);
	}

	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseSuccess(PaymentRequest $request, $orderId) {
		return HttpResponse::factory(HttpResponse::TYPE_XML,
			'<?xml version="1.0" encoding="UTF-8"?><callbacks_payment_response xmlns="http://api.forticom.com/1.0/">true</callbacks_payment_response>');
	}

	/**
	 * @param PaymentException $error
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseError(PaymentException $error) {
		switch ($error->getCode()) {
			case PaymentException::INVALID_REQUEST:
				$code = 104;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>104</error_code><error_msg>PARAM_SIGNATURE: Invalid signature</error_msg>' .
					'</ns2:error_response>';
				break;

			case PaymentException::SERVER_ERROR:
			case PaymentException::SERVER_UNAVAILABLE:
				$code = 2;
				$body = '<?xml version="1.0" encoding="UTF-8"?>' .
					'<ns2:error_response xmlns:ns2="http://api.forticom.com/1.0/">' .
					'<error_code>2</error_code><error_msg>SERVICE: Service temporary unavailable</error_msg>' .
					'</ns2:error_response>';
				break;

			case PaymentException::BAD_REQUEST_PARAMETERS:
			case PaymentException::USER_NOT_FOUND:
			case PaymentException::PRODUCT_NOT_FOUND:
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
}