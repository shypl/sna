package org.shypl.sna.impl {
	import org.shypl.common.util.NumberUtils;
	import org.shypl.sna.FriendRequest;
	import org.shypl.sna.MakeFriendsRequestHandler;
	import org.shypl.sna.MakePaymentHandler;
	import org.shypl.sna.MakeWallPostHandler;
	import org.shypl.sna.SnUser;
	import org.shypl.sna.SnUserIdListReceiver;
	import org.shypl.sna.SnUserListReceiver;
	import org.shypl.sna.SnUserReceiver;
	import org.shypl.sna.SocialNetwork;
	import org.shypl.sna.SocialNetworkAdapter;
	import org.shypl.sna.WallPost;

	public class FakeAdapter implements SocialNetworkAdapter {
		public function get available():Boolean {
			return false;
		}

		public function get network():SocialNetwork {
			return null;
		}

		public function get sessionUserId():String {
			return null;
		}

		public function getSessionUser(receiver:SnUserReceiver):void {
			receiver.receiverSnUser(null);
		}

		public function getUser(id:String, receiver:SnUserReceiver):void {
			receiver.receiverSnUser(null);
		}

		public function getUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			receiver.receiverSnUserList(new Vector.<SnUser>(0, true));
		}

		public function getFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			receiver.receiverSnUserList(new Vector.<SnUser>(0, true));
		}

		public function getAppFriendIds(receiver:SnUserIdListReceiver):void {
			receiver.receiverSnUserIdList(new Vector.<String>(0, true));
		}

		public function inviteFriends():void {
		}

		public function makePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			handler.handleMakePaymentResult(false);
		}

		public function makeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			handler.handleMakeWallPostResult(false);
		}

		public function makeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			handler.handleMakeFriendRequestResult(false);
		}

		public function getCurrencyLabelForNumber(number:Number):String {
			return NumberUtils.defineWordDeclinationRu(number, "монета", "монеты", "монет");
		}
	}
}
