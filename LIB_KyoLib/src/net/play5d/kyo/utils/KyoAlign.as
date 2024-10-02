package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class KyoAlign
	{
		public function KyoAlign()
		{
		}
		
		public static function left(A:DisplayObject , B:DisplayObject):void{
			
		}
		
		public static function right(A:DisplayObject , B:DisplayObject):void{
			
		}
		
		public static function centerH(A:DisplayObject , B:Object):void{
			var Bnum:Number;
			if(B is Number){
				Bnum = B as Number;
			}
			if(B is Point){
				var bp:Point = B as Point;
				Bnum = bp.y - bp.x;
			}
			if(B is DisplayObject){
				A.y = (B as DisplayObject).y;
				Bnum = (B as DisplayObject).height;
			}
			var diff:Number = Bnum - A.height;
			A.y += diff / 2;
		}
		
		public static function up(A:DisplayObject , B:DisplayObject):void{
			
		}
		
		public static function down(A:DisplayObject , B:DisplayObject):void{
			
		}
		
		public static function centerW(A:DisplayObject , B:Object):void{
			var Bnum:Number;
			if(B is Number){
				Bnum = B as Number;
			}
			if(B is Point){
				var bp:Point = B as Point;
				Bnum = bp.y - bp.x;
			}
			if(B is DisplayObject){
				A.x = (B as DisplayObject).x;
				Bnum = (B as DisplayObject).width;
			}
			var diff:Number = Bnum - A.width;
			A.x += diff / 2;
		}
		
		
		
	}
}