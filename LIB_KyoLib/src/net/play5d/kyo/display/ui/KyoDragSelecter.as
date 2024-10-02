package net.play5d.kyo.display.ui
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class KyoDragSelecter extends KyoDragList
	{
		public static const EVENT_CHANGE:String = 'select-change-event';
		
		private var _selectItem:DisplayObject;
		public var changeEffectObj:Object;
		private var _selectPos:Point = new Point();
		
		public function KyoDragSelecter(dispalys:Array, dragType:int=KyoDragType.DRAG_TYPE_V, hrow:int=int.MAX_VALUE, vrow:int=1)
		{
			super(dispalys, dragType, hrow, vrow);
			mouseChildren = false;
			_haveToDrag = true;
		}
		
		public function get selectItem():DisplayObject
		{
			return _selectItem;
		}

		public function set selectItem(value:DisplayObject):void
		{
			_selectItem = value;
			
			_seltid = displays.indexOf(_selectItem);
			if(_seltid != -1) dragComplete();
		}
		
		public override function update():void{
			super.update();
			displayUpdate();
		}

		protected override function draging(e:Event):void{
			var xx:Number = stage.mouseX - _downPoint.x;
			var yy:Number = stage.mouseY - _downPoint.y;
			checkDraging(xx , yy);
			
			if(!_draging) return;
			
			switch(dragType){
				case KyoDragType.DRAG_TYPE_H:
					break;
				case KyoDragType.DRAG_TYPE_V:
					this.y = _downListPoint.y + yy;
					break;
			}
			displayUpdate();
		}
		
		protected override function endDrag(e:MouseEvent):void{
			removeListener();
			removeEventListener(Event.ENTER_FRAME,draging);
			mouseEnabled = false;
			dragComplete(true);
		}
		
		private function dragComplete(sendEvent:Boolean = false):void{
			var to:Object = {
				onComplete:function():void{
					mouseEnabled = true;
					displayUpdate();
					if(sendEvent) dispatchEvent(new Event(EVENT_CHANGE));
				}
			};
			switch(dragType){
				case KyoDragType.DRAG_TYPE_H:
//					to[x] = 
					break;
				case KyoDragType.DRAG_TYPE_V:
					to['y'] = -_seltid * (unitySize.y + gap.y);
					_selectItem = displays[_seltid];
					break;
			}
			TweenLite.to(this,.2,to);
		}
		
		private var _seltid:int;
		private function displayUpdate():void{
			var uh:Number = unitySize.y + gap.y;
			_seltid = (-this.y + unitySize.y/2) / uh;
			if(_seltid < 0) _seltid = 0;
			if(_seltid > displays.length-1) _seltid = displays.length-1;
			
			if(changeEffectObj){
				for(var i:int ; i < displays.length ; i++){
					var d:DisplayObject = displays[i];
					var ms:int = Math.abs(i - _seltid);
					for(var s:String in changeEffectObj){
						d[s] = ms == 0 ? 1 : (1 / ms) * changeEffectObj[s];
					}
				}
			}
		}
	}
}