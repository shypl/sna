package org.shypl.sna.impl {
	import flash.display.Stage;

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
	import org.shypl.sna.WallPost;

	public class DevAdapter extends Adapter {
		public function DevAdapter(stage:Stage, parameters:Object) {
			super(stage, 0, parameters, 100);
		}

		override public function getCurrencyLabelForNumber(number:Number):String {
			return NumberUtils.defineWordDeclinationRu(number, "монета", "монеты", "монет");
		}

		override protected function init():void {
		}

		[Abstract]
		override protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			var list:Vector.<SnUser> = new Vector.<SnUser>(ids.length, true);
			for (var i:int = 0; i < ids.length; i++) {
				var id:String = ids[i];
				list[i] = new SnUser(id, "User-" + id, "Developer", null, SnUserGender(Enum.valueOfOrdinal(SnUserGender, i % 3)));
			}
			receiver.receiverSnUserList(list);
		}

		[Abstract]
		override protected function doGetFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			var list:Vector.<SnUser> = new Vector.<SnUser>(limit, true);
			for (var i:int = 0; i < limit; i++) {
				var id:String = String(offset + i + 1);
				list[i] = new SnUser(id, "User-" + id, "Developer", null, SnUserGender(Enum.valueOfOrdinal(SnUserGender, i % 3)));
			}
			receiver.receiverSnUserList(list);
		}

		[Abstract]
		override protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			var list:Vector.<String> = new Vector.<String>(10, true);
			for (var i:int = 0; i < list.length; i++) {
				list[i] = String(i + 1);
			}
			receiver.receiverSnUserIdList(list);
		}

		[Abstract]
		override protected function doInviteFriends():void {
			closeFullScreen();
		}

		[Abstract]
		override protected function doMakePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			closeFullScreen();
			handler.handleMakePaymentResult(false);
		}

		[Abstract]
		override protected function doMakeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			closeFullScreen();
			handler.handleMakeWallPostResult(false);
		}

		[Abstract]
		override protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			closeFullScreen();
			handler.handleMakeFriendRequestResult(false);
		}
	}
}
