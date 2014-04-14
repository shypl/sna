package org.shypl.sna
{
	internal class UsersToUserWrapper implements IUserListHandler
	{
		private var _handler:IUserHandler;

		public function UsersToUserWrapper(handler:IUserHandler)
		{
			_handler = handler;
		}

		public function handleUserList(users:Vector.<SocialNetworkUser>):void
		{
			_handler.handleUser(users.length == 0 ? null : users[0]);
			_handler = null;
		}
	}
}
