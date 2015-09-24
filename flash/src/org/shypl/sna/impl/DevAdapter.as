package org.shypl.sna.impl {
	import org.shypl.common.lang.Enum;
	import org.shypl.common.util.NumberUtils;
	import org.shypl.sna.Adapter;
	import org.shypl.sna.FriendRequest;
	import org.shypl.sna.MakeFriendsRequestHandler;
	import org.shypl.sna.MakePaymentHandler;
	import org.shypl.sna.MakeWallPostHandler;
	import org.shypl.sna.SnUser;
	import org.shypl.sna.SnUserGender;
	import org.shypl.sna.SnUserIdListReceiver;
	import org.shypl.sna.SnUserListReceiver;
	import org.shypl.sna.SnUserReceiver;
	import org.shypl.sna.SocialNetwork;
	import org.shypl.sna.SocialNetworkManager;
	import org.shypl.sna.WallPost;

	public class DevAdapter implements Adapter {
		private var _sessionUserId:String;

		public function DevAdapter(sessionUserId:String) {
			_sessionUserId = sessionUserId;
		}

		public function get network():SocialNetwork {
			return SocialNetworkManager.getNetworkById(0);
		}

		public function get sessionUserId():String {
			return _sessionUserId;
		}

		public function getSessionUser(receiver:SnUserReceiver):void {
			receiver.receiverSnUser(new SnUser(_sessionUserId, "User-" + _sessionUserId, "Developer", null, SnUserGender.MALE));
		}

		public function getUser(id:String, receiver:SnUserReceiver):void {
			receiver.receiverSnUser(new SnUser(id, "User-" + id, "Developer", null, SnUserGender.MALE));
		}

		public function getUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			var list:Vector.<SnUser> = new Vector.<SnUser>(ids.length, true);
			for (var i:int = 0; i < ids.length; i++) {
				var id:String = ids[i];
				list[i] = new SnUser(id, "User-" + id, "Developer", null, SnUserGender(Enum.valueOfOrdinal(SnUserGender, i % 3)));
			}
			receiver.receiverSnUserList(list);
		}

		public function getFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			var list:Vector.<SnUser> = new Vector.<SnUser>(limit, true);
			for (var i:int = 0; i < limit; i++) {
				var id:String = String(offset + i + 1);
				list[i] = new SnUser(id, "User-" + id, "Developer", null, SnUserGender(Enum.valueOfOrdinal(SnUserGender, i % 3)));
			}
			receiver.receiverSnUserList(list);
		}

		public function getAppFriendIds(receiver:SnUserIdListReceiver):void {
			var list:Vector.<String> = new Vector.<String>(10, true);
			for (var i:int = 0; i < list.length; i++) {
				list[i] = String(i + 1);
			}
			receiver.receiverSnUserIdList(list);
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
