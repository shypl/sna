package org.shypl.sna {
	import ru.capjack.flacy.core.errors.RuntimeException;
	
	public class SnaException extends RuntimeException {
		public function SnaException(message:String, cause:Error = null) {
			super(message, cause);
		}
	}
}
