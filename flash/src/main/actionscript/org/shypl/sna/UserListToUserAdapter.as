package org.shypl.sna {
	internal class UserListToUserAdapter implements SnUserListReceiver {
		private var _receiver:SnUserReceiver;
		
		public function UserListToUserAdapter(receiver:SnUserReceiver) {
			_receiver = receiver;
		}
		
		public function receiverSnUserList(list:Vector.<SnUser>):void {
			_receiver.receiverSnUser(list.length == 0 ? null : list[0]);
			_receiver = null;
		}
	}
}
