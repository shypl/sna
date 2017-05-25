<?php

namespace org\shypl\sna\impl;

use org\shypl\common\net\HttpRequest;
use org\shypl\common\net\HttpResponse;
use org\shypl\common\net\Url;
use org\shypl\sna\PaymentException;
use org\shypl\sna\PaymentProcessor;
use org\shypl\sna\PaymentProduct;
use org\shypl\sna\PaymentRequest;

class FbPaymentProcessor extends PaymentProcessor
{
	public static function isProductRequest(HttpRequest $request) {
		return self::extractProductIdFromProductRequest($request) != 0;
	}
	
	public static function isHubModeSubscribeRequest(HttpRequest $request) {
		return $request->getParameter("hub_mode") == "subscribe";
	}
	
	/**
	 * @return int
	 */
	public static function extractProductIdFromProductRequest(HttpRequest $request) {
		$path = $request->getUrl()->getPath();
		$path = explode('/', $path);
		if ($path >= 3) {
			$path = array_slice($path, -3);
			if (count($path) == 3 && $path[0] == 'pay' && $path[1] == 'product') {
				return intval($path[2]);
			}
		}
		return 0;
	}
	
	/**
	 * @param HttpRequest $httpRequest
	 *
	 * @return HttpResponse
	 */
	protected function doProcess(HttpRequest $httpRequest) {
		$productId = self::extractProductIdFromProductRequest($httpRequest);
		if ($productId != 0) {
			$product = $this->delegate->getPaymentProduct(new PaymentRequest(FbSocialNetwork::ID, "fake", "fake", $productId, 0));
			return $this->createProductHttpResponse($product, $httpRequest->getUrl());
		}
		
		if (self::isHubModeSubscribeRequest($httpRequest)) {
			return HttpResponse::factory(HttpResponse::TYPE_TEXT, $httpRequest->getParameter("hub_challenge"));
		}
		
		return parent::doProcess($httpRequest);
	}
	
	
	/**
	 * @param HttpRequest $request
	 *
	 * @return PaymentRequest
	 */
	public function createPaymentRequest(HttpRequest $request) {
		$request = file_get_contents("php://input");
		if (!empty($request)) {
			$request = json_decode($request);
			
			$result = file_get_contents('https://graph.facebook.com/' . $request->entry[0]->id . '?fields=user,items&access_token=' . $this->adapter->appId .
				'|' . $this->adapter->secretKey);
			
			$result = json_decode($result);
			
			
			$productId = explode('/', $result->items[0]->product);
			$productId = $productId[count($productId) - 1];
			
			return new PaymentRequest(FbSocialNetwork::ID, $result->id, $result->user->id, $productId, 0);
		}
		
		throw new PaymentException(PaymentException::INVALID_REQUEST);
	}
	
	/**
	 * @param PaymentRequest $request
	 * @param string         $orderId
	 *
	 * @return HttpResponse
	 */
	public function createHttpResponseSuccess(PaymentRequest $request, $orderId) {
		return HttpResponse::factory(HttpResponse::TYPE_TEXT, "ok");
	}
	
	/**
	 * @param PaymentException $error
	 * @return HttpResponse
	 */
	public function createHttpResponseError(PaymentException $error) {
		return HttpResponse::factory(HttpResponse::TYPE_JSON,
			array('error' => array('code' => $error->getCode(), 'message' => $error->getMessage(), 'critical' => $error->isCritical())));
	}
	
	/**
	 * @param PaymentProduct $product
	 * @param Url            $url
	 * @return HttpResponse
	 */
	private function createProductHttpResponse(PaymentProduct $product, Url $url) {
		
		$url = $url->getScheme() . '://' . $url->getHost() . $url->getPath();
		$content
			= '<!DOCTYPE html><html>
 <head prefix=
    "og: http://ogp.me/ns#
     fb: http://ogp.me/ns/fb#
     product: http://ogp.me/ns/product#">
    <meta property="og:type"                   content="og:product" />
    <meta property="og:title"                  content="' . $product->getName() . '" />
    <meta property="og:image"                  content="' . $product->getImage() . '" />
    <meta property="og:description"            content="' . $product->getName() . '" />
    <meta property="og:url"                    content="' . $url . '" />
    <meta property="product:price:amount"      content="' . $product->getPrice() . '"/>
    <meta property="product:price:currency"    content="USD"/>
  </head>
</html>';
		
		$response = HttpResponse::factory(HttpResponse::TYPE_HTML, $content);
		$response->addHeader('Expires', 'Thu, 01 Jan 1970 00:00:00 GMT');
		$response->addHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
		$response->addHeader('Cache-Control', 'post-check=0, pre-check=0');
		$response->addHeader('Cache-Control', 'max-age=0');
		$response->addHeader('Pragma', 'no-cache');
		
		return $response;
	}
}