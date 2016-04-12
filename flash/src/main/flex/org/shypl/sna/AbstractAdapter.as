package org.shypl.sna {
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.shypl.common.collection.LinkedList;
	import org.shypl.common.lang.AbstractMethodException;

	public class AbstractAdapter implements SocialNetworkAdapter {
		private var _network:SocialNetwork;
		private var _sessionUserId:String;
		private var _stage:Stage;

		private var _getUsersLimit:int;
		private var _callQueue:LinkedList = new LinkedList();
		private var _callTimer:Timer = new Timer(400, 1);
		private var _lastCallbackHandlerId:int = 0;
		private var _callbackHandlers:Object = {};

		public function AbstractAdapter(networkId:int, getUsersLimit:int, stage:Stage, sessionUserId:String) {
			_network = SocialNetworkManager.getNetworkById(networkId);
			_getUsersLimit = getUsersLimit;
			_stage = stage;
			_sessionUserId = sessionUserId;

			_callTimer.addEventListener(TimerEvent.TIMER, onCallTimerEvent);
		}

		public final function get available():Boolean {
			return true;
		}

		public final function get network():SocialNetwork {
			return _network;
		}

		public final function get sessionUserId():String {
			return _sessionUserId;
		}

		public final function getSessionUser(receiver:SnUserReceiver):void {
			getUser(_sessionUserId, receiver);
		}

		public final function getUser(id:String, receiver:SnUserReceiver):void {
			getUsers(new <String>[id], new UserListToUserAdapter(receiver));
		}

		public final function getUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			const len:uint = ids.length;

			if (len == 0) {
				receiver.receiverSnUserList(new <SnUser>[]);
			}
			else {
				if (len > _getUsersLimit) {
					receiver = new UserListCompositeDelegate(receiver, Math.ceil(len / _getUsersLimit));
					for (var i:int = 0; i <= len; i += _getUsersLimit) {
						getUsers(ids.slice(i, i + _getUsersLimit), receiver);
					}
				}
				else {
					pushCall(doGetUsers, arguments);
				}
			}
		}

		public final function getFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			if (limit == 0) {
				receiver.receiverSnUserList(new <SnUser>[]);
			}
			else {
				pushCall(doGetFriends, arguments);
			}
		}

		public final function getAppFriendIds(receiver:SnUserIdListReceiver):void {
			pushCall(doGetAppFriendIds, arguments);
		}

		public final function inviteFriends():void {
			pushCall(doInviteFriends, arguments);
		}

		public final function makePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			pushCall(doMakePayment, arguments);
		}

		public final function makeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			pushCall(doMakeWallPost, arguments);
		}

		public final function makeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			pushCall(doMakeFriendsRequest, arguments);
		}

		[Abstract]
		public function getCurrencyLabelForNumber(number:Number):String {
			throw new AbstractMethodException();
		}

		protected final function registerCallbackHandler(handler:Object):int {
			if (handler == null) {
				return -1;
			}
			_callbackHandlers[++_lastCallbackHandlerId] = handler;
			return _lastCallbackHandlerId;
		}

		protected final function getCallbackHandler(callbackId:int):Object {
			const handler:Object = _callbackHandlers[callbackId];
			delete _callbackHandlers[callbackId];
			return handler;
		}

		protected final function closeFullScreen():void {
			if (_stage.displayState != StageDisplayState.NORMAL) {
				_stage.displayState = StageDisplayState.NORMAL
			}
		}

		[Abstract]
		protected function doGetUsers(ids:Vector.<String>, receiver:SnUserListReceiver):void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doGetFriends(limit:int, offset:int, receiver:SnUserListReceiver):void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doGetAppFriendIds(receiver:SnUserIdListReceiver):void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doInviteFriends():void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakePayment(id:int, name:String, price:int, handler:MakePaymentHandler):void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakeWallPost(post:WallPost, handler:MakeWallPostHandler):void {
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:MakeFriendsRequestHandler):void {
			throw new AbstractMethodException();
		}

		private function pushCall(method:Function, args:Array):void {
			if (!_callTimer.running) {
				method.apply(this, args);
				runCallTimer();
			}
			else {
				_callQueue.add(new CallQueueItem(method, args));
			}
		}

		private function runCallTimer():void {
			_callTimer.reset();
			_callTimer.start();
		}

		private function executeNextCall():void {
			if (!_callQueue.isEmpty()) {
				CallQueueItem(_callQueue.removeFirst()).execute();
				if (!_callQueue.isEmpty()) {
					runCallTimer();
				}
			}
		}

		private function onCallTimerEvent(event:TimerEvent):void {
			executeNextCall();
		}
	}
}
