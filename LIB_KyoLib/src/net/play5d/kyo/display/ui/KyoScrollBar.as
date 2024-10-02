package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import net.play5d.kyo.utils.KyoUtils;

	public class KyoScrollBar extends EventDispatcher implements IKyoScrollBar
	{
		public static const TYPE_H:int = 0;
		public static const TYPE_V:int = 1;
		
		public var ui:Sprite;
		private var _dragRange:Point;
		private var _type:int;
		private var _distance:Number;
		
		public function KyoScrollBar(ui:Sprite , dragRange:Point , type:int = TYPE_V)
		{
			this.ui = ui;
			this._dragRange = dragRange;
			this._type = type;
			_distance = _dragRange.y - _dragRange.x;
			
			ui.mouseChildren = false;
			ui.addEventListener(MouseEvent.MOUSE_DOWN,startDrag);
		}
		
		public function set enabled(v:Boolean):void{
			ui.mouseEnabled = v;
			if(!v) endDrag();
		}
		
		private var _draging:Boolean;
		private function startDrag(e:MouseEvent):void{
			if(_draging) return;
			_draging = true;
			
			ui.stage.addEventListener(MouseEvent.MOUSE_UP,endDrag);
			
			ui.addEventListener(Event.ENTER_FRAME,onEnterframe);
		}
		
		private function onEnterframe(e:Event):void{
			var pp:Number;
			var pos:Point = new Point();
			if(_type == TYPE_H){
				pp = KyoUtils.num_fixRange(ui.parent.mouseX , _dragRange);
				ui.x = pp;
				pos.x = (pp - _dragRange.x) / _distance;
			}
			if(_type == TYPE_V){
				pp = KyoUtils.num_fixRange(ui.parent.mouseY , _dragRange);
				ui.y = pp;
				pos.y = (pp - _dragRange.x) / _distance;
			}
			dispatchEvent(new KyoUIEvent(KyoUIEvent.UPDATE,pos));
		}
		
		private function endDrag(e:MouseEvent = null):void{
			_draging = false;
			ui.removeEventListener(Event.ENTER_FRAME,onEnterframe);
			if(ui.stage) ui.stage.removeEventListener(MouseEvent.MOUSE_UP,endDrag);
		}
		
		public function update(pos:Number):void
		{
			var pp:Number = pos * _distance;
			if(_type == TYPE_H){
				ui.x = _dragRange.x + pp;
			}
			if(_type == TYPE_V){
				ui.y = _dragRange.x + pp;
			}
		}
	}
}