package org.shypl.sna
{
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.shypl.common.collection.LinkedList;
	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.logging.ILogger;
	import org.shypl.common.util.CollectionUtils;
	import org.shypl.common.util.Destroyable;
	import org.shypl.common.util.IErrorHandler;

	[Abstract]
	public class SocialNetworkAdapter extends Destroyable
	{
		public static function factoryByServerParams(stage:Stage, errorHandler:IErrorHandler, params:String):SocialNetworkAdapter
		{
			const paramsArray:Array = params.split(";");
			const paramsObject:Object = {};
			const code:String = paramsArray.shift();

			for each (var entry:String in paramsArray) {
				var i:int = entry.indexOf("=");
				paramsObject[entry.substr(0, i)] = entry.substr(i + 1);
			}

			return factory(stage, errorHandler, code, paramsObject);
		}

		public static function factory(stage:Stage, errorHandler:IErrorHandler, code:String, params:Object):SocialNetworkAdapter
		{
			return SocialNetwork.getByCode(code).createAdapter(stage, errorHandler, params);
		}

		protected var _stage:Stage;
		protected var _logger:ILogger;
		private var _errorHandler:IErrorHandler;
		private var _network:SocialNetwork;
		private var _sessionUserId:String;
		private var _inited:Boolean;
		private var _callQueue:LinkedList = new LinkedList();
		private var _callTimer:Timer = new Timer(400, 1);
		private var _lastCallbackId:int = 0;
		private var _handlers:Object = {};

		public function SocialNetworkAdapter(stage:Stage, errorHandler:IErrorHandler, network:SocialNetwork, params:Object, logger:ILogger)
		{
			_stage = stage;
			_errorHandler = errorHandler;
			_network = network;
			_logger = logger;
			_sessionUserId = params.u;

			_callTimer.addEventListener(TimerEvent.TIMER, handleCallTimerEvent);
		}

		public final function get network():SocialNetwork
		{
			abortIfDestroyed();
			return _network;
		}

		public final function get sessionUserId():String
		{
			abortIfDestroyed();
			return _sessionUserId;
		}

		public final function getSessionUser(handler:IUserHandler):void
		{
			getUser(_sessionUserId, handler);
		}

		public final function getUser(id:String, handler:IUserHandler):void
		{
			getUsers(new <String>[id], new UsersToUserWrapper(handler));
		}

		public final function getUsers(ids:Vector.<String>, handler:IUserListHandler):void
		{
			pushCall(doGetUsers, arguments);
		}

		public final function getFriends(limit:int, offset:int, handler:IUserListHandler):void
		{
			pushCall(doGetFriends, arguments);
		}

		public final function getAppFriendIds(handler:IUserIdListHandler):void
		{
			pushCall(doGetAppFriendIds, arguments);
		}

		public final function inviteFriends():void
		{
			pushCall(doInviteFriends, arguments);
		}

		public final function makePayment(id:int, name:String, price:int, handler:IMakePaymentHandler):void
		{
			pushCall(doMakePayment, arguments);
		}

		public final function makeWallPost(userId:String, post:WallPost, handler:IMakeWallPostHandler):void
		{
			pushCall(doMakeWallPost, arguments);
		}

		public final function makeFriendsRequest(userId:String, request:FriendRequest, handler:IMakeFriendsRequestHandler):void
		{
			pushCall(doMakeFriendsRequest, arguments);
		}

		override protected function doDestroy():void
		{
			_network = null;
			_sessionUserId = null;
			_inited = false;
			_callQueue.clear();
			_callQueue = null;
			_callTimer.stop();
			_callTimer.removeEventListener(TimerEvent.TIMER, handleCallTimerEvent);
			_callTimer = null;

			CollectionUtils.clear(_handlers);
			_handlers = null;
		}

		protected function catchError(error:SocialNetworkError):void
		{
			_logger.error(error.toString());
			_errorHandler.handleError(error);
			destroy();
		}

		protected final function completeInit():void
		{
			if (!destroyed) {
				_inited = true;
				executeCall();
			}
		}

		protected final function registerCallbackHandler(handler:Object):int
		{
			_handlers[++_lastCallbackId] = handler;
			return _lastCallbackId;
		}

		protected final function getCallbackHandler(callbackId:int):Object
		{
			const handler:Object = _handlers[callbackId];
			delete _handlers[callbackId];
			return handler;
		}

		[Abstract]
		protected function doGetUsers(ids:Vector.<String>, handler:IUserListHandler):void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doGetFriends(limit:int, offset:int, handler:IUserListHandler):void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doGetAppFriendIds(handler:IUserIdListHandler):void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doInviteFriends():void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakePayment(id:int, name:String, price:int, handler:IMakePaymentHandler):void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakeWallPost(userId:String, post:WallPost, handler:IMakeWallPostHandler):void
		{
			throw new AbstractMethodException();
		}

		[Abstract]
		protected function doMakeFriendsRequest(userId:String, request:FriendRequest, handler:IMakeFriendsRequestHandler):void
		{
			throw new AbstractMethodException();
		}

		protected function closeFullScreen():void
		{
			if (_stage.displayState != StageDisplayState.NORMAL) {
				_stage.displayState = StageDisplayState.NORMAL
			}
		}

		private function pushCall(method:Function, args:Array):void
		{
			abortIfDestroyed();

			if (_inited && !_callTimer.running) {
				method.apply(this, args);
				runCallTimer();
			}
			else {
				_callQueue.add(new CallQueueItem(method, args));
			}
		}

		private function executeCall():void
		{
			if (!_callQueue.empty) {
				CallQueueItem(_callQueue.removeFirst()).execute();
				if (!_callQueue.empty) {
					runCallTimer();
				}
			}
		}

		private function runCallTimer():void
		{
			_callTimer.reset();
			_callTimer.start();
		}

		private function handleCallTimerEvent(event:TimerEvent):void
		{
			executeCall();
		}
	}
}
