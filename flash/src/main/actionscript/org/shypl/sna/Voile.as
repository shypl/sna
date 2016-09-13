package org.shypl.sna {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import org.shypl.common.lang.notNull;
	import org.shypl.common.timeline.GlobalTimeline;
	import org.shypl.common.util.Cancelable;
	
	internal class Voile {
		private var _view:Sprite = new Sprite();
		private var _stage:Stage;
		private var _callback:Function;
		private var _timer:Cancelable;
		
		public function Voile(stage:Stage, callback:Function) {
			_stage = stage;
			_callback = callback;
			
			_view.mouseEnabled = true;
			_view.graphics.beginFill(0, 0.9);
			_view.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			_view.graphics.endFill();
			
			_stage.addChild(_view);
			
			_timer = GlobalTimeline.schedule(1000, startListenMouse);
		}
		
		public function hide():void {
			if (notNull(_stage)) {
				cancelTimer();
				stopListenMouse();
				_stage.removeChild(_view);
				_stage = null;
				_callback = null;
				_view = null;
			}
		}
		
		private function cancelTimer():void {
			if (notNull(_timer)) {
				_timer.cancel();
				_timer = null;
			}
		}
		
		private function startListenMouse():void {
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
		}
		
		private function stopListenMouse():void {
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
		}
		
		private function callCallback():void {
			if (notNull(_callback)) {
				_callback.apply();
			}
		}
		
		private function onMouseEvent(event:MouseEvent):void {
			stopListenMouse();
			_timer = GlobalTimeline.schedule(1000, callCallback);
		}
	}
}
