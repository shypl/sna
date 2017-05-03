package org.shypl.sna {
	internal class UserListCompositeDelegate implements SnUserListReceiver {
		private var _result:Vector.<SnUser> = new Vector.<SnUser>();
		private var _receiver:SnUserListReceiver;
		private var _expectedParts:int;
		private var _receivedParts:int;
		
		public function UserListCompositeDelegate(receiver:SnUserListReceiver, parts:int) {
			_receiver = receiver;
			_expectedParts = parts;
		}
		
		public function receiverSnUserList(list:Vector.<SnUser>):void {
			_result = _result.concat(list);
			if (++_receivedParts == _expectedParts) {
				_receiver.receiverSnUserList(_result);
				_receiver = null;
				_result = null;
			}
		}
	}
}