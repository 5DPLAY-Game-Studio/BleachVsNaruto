package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class KyoDragUtils
	{
		public function KyoDragUtils()
		{
		}
		
		public static function dragBase(downmc:DisplayObject , onDown:Function = null , onUp:Function = null , onMove:Function = null):void{
			downmc.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			function onMouseDown(e:MouseEvent):void{
				if(!downmc.stage) return;
				if(onDown != null){
					var dv:* = onDown();
					if(dv is Boolean && dv == false) return;
				}
				
				if(downmc.stage){
					downmc.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
					downmc.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				}else{
					downmc.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
					downmc.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				}
				
			}
			function onMouseUp(e:MouseEvent):void{
				if(onUp != null){
					var uv:* = onUp();
					if(uv is Boolean && uv == false) return;
				}
				
				if(downmc.stage){
					downmc.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
					downmc.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				}else{
					downmc.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
					downmc.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				}
				
			}
			function onMouseMove(e:MouseEvent):void{
				if(onMove != null) onMove();
			}
		}
		
		public static function dragSimple(downmc:Sprite , params:Object = null):void{
			var onDown:Function,onUp:Function,onMove:Function;
			var dragmc:Sprite,bounds:Rectangle,lockCenter:Boolean;
			if(params){
				onDown = params.onDown;
				onUp = params.onUp;
				onMove = params.onMove;
				dragmc = params.dragmc;
				bounds = params.bounds;
				lockCenter = params.lockCenter;
			}
			
			dragmc ||= downmc;
			dragBase(downmc,simDown,simUp,simMove);
			function simDown():Boolean{
				if(onDown != null && !onDown()) return false;
				dragmc.startDrag(lockCenter,bounds);
				return true;
			}
			function simUp():Boolean{
				if(onUp != null && !onUp()) return false;
				dragmc.stopDrag();
				return true;
			}
			function simMove():void{
				if(onMove != null) onMove();
			}
		}
		
	}
}