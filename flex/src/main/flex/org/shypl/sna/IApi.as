package org.shypl.sna
{
	public interface IApi
	{
		function getSessionUser(handler:IUserHandler):void;

		function getUser(id:String, handler:IUserHandler):void;

		function getUsers(ids:Vector.<String>, handler:IUserListHandler):void

		function getFriends(limit:int, offset:int, handler:IUserListHandler):void

		function getAppFriends(handler:IUserIdListHandler):void
	}
}
