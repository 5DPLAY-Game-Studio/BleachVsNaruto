package net.play5d.game.bvn.debug
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import net.play5d.game.bvn.utils.DebugSprite;

	public class DebugUtil
	{
		private static const map:Dictionary = new Dictionary();
		
		public function DebugUtil()
		{
		}
		
		
		public static const enabled:Boolean = true;
		
		public static function debugPosition(d:DisplayObject, container:DisplayObjectContainer = null):void{
			if(!enabled) return;
			
			if(map[d]){
				(map[d] as DebugSprite).destory();
			}
			
			if(!d.parent && !container){
				trace("debugPosition 失败");
				return;
			}
			
			container ||= d.parent;
			
			var box:DebugSprite = new DebugSprite(0xffff00, d);
			box.alpha = 0.3;
			container.addChild(box);
			
			box.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);
			
			map[d] = box;
			
			function startDrag(e:MouseEvent):void{
				var t:DebugSprite = e.currentTarget as DebugSprite;
				if(t.parent) t.parent.addChild(t);
				
				t.alpha = 0.7;
				t.startDrag(false);
				t.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
			}
			
			function stopDrag(e:MouseEvent):void{
				var t:DebugSprite = e.currentTarget as DebugSprite;
				t.alpha = 0.1;
				
				t.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);
				
				t.stopDrag();
				t.applySet();
			}
			
		}
		
	}
}