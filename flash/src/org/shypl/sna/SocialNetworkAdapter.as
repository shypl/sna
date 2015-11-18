package org.shypl.sna {
	public interface SocialNetworkAdapter {
		function get network():SocialNetwork;

		function get sessionUserId():String;

		function getSessionUser(receiver:SnUserReceiver):void;

		function getUser(id:String, receiver:SnUserReceiver):void;

		function getUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void;

		function getFriends(limit:int, offset:int, receiver:SnUserListReceiver):void;

		function getAppFriendIds(receiver:SnUserIdListReceiver):void;

		function inviteFriends():void;

		function makePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void;

		function makeWallPost(post:WallPost, handler:MakeWallPostHandler):void;

		function makeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void;

		function getCurrencyLabelForNumber(number:Number):String;
	}
}
