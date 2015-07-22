package org.shypl.sna {
	import org.shypl.common.lang.RuntimeException;

	public class SnaException extends RuntimeException {
		public function SnaException(message:String, cause:Error = null) {
			super(message, cause);
		}
	}
}
