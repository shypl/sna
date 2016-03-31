<?php
namespace org\shypl\sna;

class ApiErrorException extends \RuntimeException {

	/**
	 * @var mixed
	 */
	private $data;

	/**
	 * @param string $message
	 * @param mixed $data
	 */
	public function __construct($message, $data = null) {
		parent::__construct($message);
		$this->data = $data;
	}

	/**
	 * @return mixed
	 */
	public function data() {
		return $this->data;
	}
}