package net.play5d.game.bvn.utils
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.GameConfig;
	
	public class PayUtils
	{
		public function PayUtils()
		{
		}
		
		private static var _orgRect:Rectangle;
		
		public static function getPaySp(bp:Bitmap):Sprite{
			var sp:Sprite = new Sprite();
			sp.buttonMode = true;
			sp.addChild(bp);
			sp.addEventListener(MouseEvent.MOUSE_UP,payMouseHandler,false,0,true);
			return sp;
		}
		
		private static function payMouseHandler(e:MouseEvent):void{
			
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			var sp:Sprite = e.currentTarget as Sprite;
			if(!sp) return;
			
			var bp:DisplayObject = sp.getChildAt(0);
			
			if(_orgRect && sp.width != _orgRect.width){
				sp.graphics.clear();
				if(bp){
					bp.scaleX = bp.scaleY = 1;
					bp.x = 0;
					bp.y = 0;
				}
				sp.x = _orgRect.x;
				sp.y = _orgRect.y;
				sp.width = _orgRect.width;
				sp.height = _orgRect.height;
				
				_orgRect = null;
				return;
			}
			
			_orgRect = new Rectangle(sp.x,sp.y,sp.width,sp.height);
			
			sp.graphics.beginFill(0,0.7);
			sp.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y + 20);
			sp.graphics.endFill();
			
			sp.parent.addChild(sp);
			
			sp.x = 0;
			sp.y = 0;
			sp.width = GameConfig.GAME_SIZE.x;
			sp.height = GameConfig.GAME_SIZE.y;
			
			if(bp){
				bp.scaleX = bp.scaleY = 0.8;
				bp.x = (GameConfig.GAME_SIZE.x - bp.width) / 2;
				bp.y = (GameConfig.GAME_SIZE.y - bp.height) / 2;
			}
			
		}
		
	}
}