package org.shypl.sna {
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.utils.setInterval;

	import org.shypl.common.collection.LinkedList;
	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.logging.LogManager;
	import org.shypl.common.logging.Logger;

	[Abstract]
	public class Adapter {
		protected const logger:Logger = LogManager.getLoggerByClass(Adapter);

		private var _stage:Stage;
		private var _networkId:int;
		private var _sessionUserId:String;

		private var _inited:Boolean;
		private var _getUsersLimit:int;
		private var _callQueue:LinkedList = new LinkedList();
		private var _callTimer:Timer = new Timer(400, 1);
		private var _lastCallbackHandlerId:int = 0;
		private var _callbackHandlers:Object = {};

		public function Adapter(stage:Stage, networkId:int, parameters:Object, getUsersLimit:int) {
			_stage = stage;
			_networkId = networkId;
			_getUsersLimit = getUsersLimit;
			_sessionUserId = parameters.uid;

			_callTimer.addEventListener(TimerEvent.TIMER, onCallTimerEvent);

			setInterval(startInit, 1);
		}

		public final function get networkId():int {
			return _networkId;
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

		protected final function catchException(error:SnaException):void {
			logger.errorException(error);
			throw error;
		}

		[Abstract]
		protected function init():void {
			throw new AbstractMethodException();
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

		private function startInit():void {
			logger.debug("Initialization start");
			try {
				ExternalInterface.addCallback("__sna_completeInit", completeInit);
				init();
			}
			catch (e:Error) {
				catchException(new SnaException("Initialization interrupted", e));
			}
		}

		private function completeInit():void {
			_inited = true;
			runCallTimer();
			logger.debug("Initialization complete");
		}

		private function pushCall(method:Function, args:Array):void {
			if (_inited && !_callTimer.running) {
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
