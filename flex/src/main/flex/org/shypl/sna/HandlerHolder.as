package org.shypl.sna
{
	internal class HandlerHolder
	{
		public static const USER:int = 1;
		public static const USER_LIST:int = 2;
		public static const USER_ID_LIST:int = 3;

		public var type:int;
		public var handler:Object;

		public function HandlerHolder(type:int, handler:Object)
		{
			this.type = type;
			this.handler = handler;
		}
	}
}
