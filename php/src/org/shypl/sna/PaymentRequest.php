<?php
namespace org\shypl\sna;

class PaymentRequest {
	private $orderId;
	private $userId;
	private $productId;
	private $productPrice;

	/**
	 * @param string $orderId
	 * @param string $userId
	 * @param string $productId
	 * @param int    $productPrice
	 */
	public function __construct($orderId, $userId, $productId, $productPrice) {
		$this->orderId = $orderId;
		$this->userId = $userId;
		$this->productId = $productId;
		$this->productPrice = (int)$productPrice;

		if (!$this->orderId || !$this->userId || !$this->productId || !$this->productPrice) {
			throw new PaymentException(PaymentException::BAD_REQUEST_PARAMETERS);
		}
	}

	/**
	 * @return string
	 */
	public function getOrderId() {
		return $this->orderId;
	}

	/**
	 * @return string
	 */
	public function getUserId() {
		return $this->userId;
	}

	/**
	 * @return string
	 */
	public function getProductId() {
		return $this->productId;
	}

	/**
	 * @return int
	 */
	public function getProductPrice() {
		return $this->productPrice;
	}
}