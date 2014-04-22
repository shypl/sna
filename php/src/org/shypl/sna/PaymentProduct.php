<?php
namespace org\shypl\sna;

class PaymentProduct {
	/**
	 * @var string
	 */
	private $id;
	/**
	 * @var string
	 */
	private $name;
	/**
	 * @var int
	 */
	private $price;
	/**
	 * @var string
	 */
	private $image;
	/**
	 * @var int
	 */
	private $expiration;

	/**
	 * @param string $id
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
	 * @return string
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
	public function price() {
		return $this->price;
	}

	/**
	 * @return string
	 */
	public function image() {
		return $this->image;
	}

	/**
	 * @return int
	 */
	public function expiration() {
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