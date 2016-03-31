<?php
namespace org\shypl\sna;

class PaymentProduct {
	private $id;
	private $name;
	private $price;
	private $image;
	private $expiration;

	/**
	 * @param int    $id
	 * @param string $name
	 * @param int    $price
	 * @param string $image
	 * @param int    $expiration
	 */
	public function __construct($id, $name, $price, $image = null, $expiration = 0) {
		$this->id = $id;
		$this->name = $name;
		$this->price = $price;
		$this->image = $image;
		$this->expiration = $expiration;
	}

	/**
	 * @return int
	 */
	public function getNetworkId() {
		return $this->networkId;
	}

	/**
	 * @return int
	 */
	public function getId() {
		return $this->id;
	}

	/**
	 * @return string
	 */
	public function getName() {
		return $this->name;
	}

	/**
	 * @return int
	 */
	public function getPrice() {
		return $this->price;
	}

	/**
	 * @return null|string
	 */
	public function getImage() {
		return $this->image;
	}

	/**
	 * @return int
	 */
	public function getExpiration() {
		return $this->expiration;
	}

	/**
	 * @return bool
	 */
	public function hasImage() {
		return !!$this->image;
	}

	/**
	 * @return bool
	 */
	public function hasExpiration() {
		return $this->expiration > 0;
	}
}