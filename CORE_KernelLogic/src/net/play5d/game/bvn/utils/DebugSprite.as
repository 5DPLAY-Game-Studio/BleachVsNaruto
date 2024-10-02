package net.play5d.game.bvn.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class DebugSprite extends Sprite{
		public var target:DisplayObject;
		
		
		public function DebugSprite(color:uint, target:DisplayObject = null){
			
			var w:Number = target.width < 30 ? 30 : target.width;
			var h:Number = target.height < 30 ? 30 : target.height;
			
			this.x = target.x;
			this.y = target.y;
			this.graphics.beginFill(color, 1);
			this.graphics.drawRect(0, 0, w, h);
			
			this.target = target;
		}
		
		public function applySet():void{
			target.x = x;
			target.y = y;
			
			trace("================== debug apply set ========================");
			trace("x:", target.x, "y:", target.y, "width:", target.width, "height:", target.height);
			trace("-----------------------------------------------------------");
		}
		
		public function destory():void{
			target = null;
			try{
				this.parent.removeChild(this);
			}catch(e:Error){}
		}
		
	}
	
}