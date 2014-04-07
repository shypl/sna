<?php
namespace org\shypl\sna;

class PaymentProduct
{
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
	private $img;

	/**
	 * @param string $id
	 * @param string $name
	 * @param int    $price
	 * @param string $img
	 */
	public function __construct($id, $name, $price, $img = null)
	{
		$this->id = $id;
		$this->name = $name;
		$this->price = $price;
		$this->img = $img;
	}

	/**
	 * @return string
	 */
	public function id()
	{
		return $this->id;
	}

	/**
	 * @return string
	 */
	public function name()
	{
		return $this->name;
	}

	/**
	 * @return int
	 */
	public function price()
	{
		return $this->price;
	}

	/**
	 * @return string
	 */
	public function img()
	{
		return $this->img;
	}
}