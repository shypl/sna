package org.shypl.sna
{
	import org.shypl.common.lang.RuntimeException;

	public class ApiException extends RuntimeException
	{
		public function ApiException(message:String = null, cause:Error = null)
		{
			super(message, cause);
		}
	}
}
