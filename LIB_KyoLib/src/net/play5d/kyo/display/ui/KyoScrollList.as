package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class KyoScrollList extends KyoTileList
	{
		private var _scrollType:int;
		private var _size:Point;
		public function KyoScrollList(displays:Array=null, size:Point = null , scrollType:int = 0)
		{
			_scrollType = scrollType;
			_size = size;
			var hrow:int = scrollType == 0 ? int.MAX_VALUE : 1;
			var vrow:int = scrollType == 1 ? int.MAX_VALUE : 1;
			
			scrollRect = new Rectangle(0,0,_size.x,_size.y);
			
			super(displays, hrow , vrow);
		}
		
		private var _rollSpeed:Number;
		private var _targetPos:Number;
		public function roll(speed:Number):void{
			_rollSpeed = speed;
			
			var addn:int = 0;
			
			switch(_scrollType){
				case 0:
					addn = Math.ceil(_size.x / (unitySize.x+gap.x));
					_targetPos = displays.length * (unitySize.x+gap.x);
					break;
				case 1:
					addn = Math.ceil(_size.y / (unitySize.y+gap.y));
					_targetPos = displays.length * (unitySize.y+gap.y);
					break;
			}
			
			if(addn >= displays.length) return;
			
			for(var i:int ; i < addn ; i++){
				displays.push(displays[i].clone());
			}
			
			update();
			
			addEventListener(Event.ENTER_FRAME,enterFrame);
		}
		
		private function enterFrame(e:Event):void{
			if(!_size) return;
			
			var srx:Number = scrollRect.x;
			var sry:Number = scrollRect.y;
			var sx:Number = 0 , sy:Number = 0;
			switch(_scrollType){
				case 0:
					sx = _rollSpeed;
					if(srx > _targetPos) srx = 0;
					if(srx < 0) srx = _targetPos;
					break;
				case 1:
					sy = _rollSpeed;
					if(sry > _targetPos) sry = 0;
					if(sry < 0) sry = _targetPos;
					break;
			}
			
			scrollRect = new Rectangle(srx + sx , sry + sy , _size.x , _size.y);
		}
		
	}
}