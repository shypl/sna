<?php
namespace org\shypl\sna;

class UserSession {
	private $userId;
	private $flashAdapterParameters;

	/**
	 * @param string $userId
	 * @param array  $flashAdapterParameters
	 */
	public function __construct($userId, array $flashAdapterParameters) {
		$this->userId = $userId;
		$this->flashAdapterParameters = $flashAdapterParameters;
	}

	/**
	 * @return string
	 */
	public function getUserId() {
		return $this->userId;
	}

	/**
	 * @return array
	 */
	public function getFlashAdapterParameters() {
		return $this->flashAdapterParameters;
	}

	/**
	 * @return string
	 */
	public function getFlashAdapterParametersJavaScriptDeclaration() {
		return '<script>function __sna_fap(){return ' . json_encode($this->flashAdapterParameters) . ';}</script>';

	}

}