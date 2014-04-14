package org.shypl.sna
{
	import org.shypl.common.lang.RuntimeException;

	public class SocialNetworkError extends RuntimeException
	{
		public function SocialNetworkError(message:String = null, cause:Error = null)
		{
			super(message, cause);
		}
	}
}
