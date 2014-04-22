<?php
namespace org\shypl\sna;

class PaymentRequest {
	/**
	 * @var string
	 */
	private $orderId;
	/**
	 * @var string
	 */
	private $userId;
	/**
	 * @var string
	 */
	private $productId;
	/**
	 * @var int
	 */
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
	}

	/**
	 * @return string
	 */
	public function orderId() {
		return $this->orderId;
	}

	/**
	 * @return string
	 */
	public function productId() {
		return $this->productId;
	}

	/**
	 * @return int
	 */
	public function productPrice() {
		return $this->productPrice;
	}

	/**
	 * @return string
	 */
	public function userId() {
		return $this->userId;
	}
}