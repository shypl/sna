package org.shypl.sna
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.shypl.common.collection.LinkedList;
	import org.shypl.common.lang.AbstractMethodException;
	import org.shypl.common.util.CollectionUtils;
	import org.shypl.common.util.Destroyable;
	import org.shypl.common.util.IErrorHandler;

	[Abstract]
	public class SocialNetworkAdapter extends Destroyable
	{
		public static function factoryByServerParams(errorHandler:IErrorHandler, params:String):SocialNetworkAdapter
		{
			const paramsArray:Array = params.split(";");
			const paramsObject:Object = {};
			const code:String = paramsArray.shift();

			for each (var entry:String in paramsArray) {
				var i:int = entry.indexOf("=");
				paramsObject[entry.substr(0, i)] = entry.substr(i + 1);
			}

			return factory(errorHandler, code, paramsObject);
		}

		public static function factory(errorHandler:IErrorHandler, code:String, params:Object):SocialNetworkAdapter
		{
			return SocialNetwork.getByCode(code).createAdapter(errorHandler, params);
		}

		private var _network:SocialNetwork;
		private var _sessionUserId:String;
		private var _inited:Boolean;
		private var _callQueue:LinkedList = new LinkedList();
		private var _callTimer:Timer = new Timer(400, 1);
		private var _lastCallbackId:int = 0;
		private var _handlers:Object = {};
		private var _errorHandler:IErrorHandler;

		public function SocialNetworkAdapter(network:SocialNetwork, errorHandler:IErrorHandler, params:Object)
		{
			_network = network;
			_errorHandler = errorHandler;
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
