<?php
namespace org\shypl\sna;

class PaymentRequest {
	private $networkId;
	private $orderId;
	private $userId;
	private $productId;
	private $productPrice;

	/**
	 * @param int $networkId
	 * @param string $orderId
	 * @param string $userId
	 * @param int $productId
	 * @param int $productPrice
	 *
	 * @throws PaymentException
	 */
	public function __construct($networkId, $orderId, $userId, $productId, $productPrice) {
		$this->networkId = (int)$networkId;
		$this->orderId = $orderId;
		$this->userId = $userId;
		$this->productId = (int)$productId;
		$this->productPrice = (int)$productPrice;

		if (!$this->orderId || !$this->userId || !$this->productId) {
			throw new PaymentException(PaymentException::BAD_REQUEST_PARAMETERS);
		}
	}

	/**
	 * @return int
	 */
	public function getNetworkId() {
		return $this->networkId;
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
	 * @return int
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