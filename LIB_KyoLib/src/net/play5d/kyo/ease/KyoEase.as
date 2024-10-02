package net.play5d.kyo.ease
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	public class KyoEase
	{
		public function KyoEase()
		{
		}
		
		/**
		 * 抛物线动物 
		 * 
		 */
		/**
		 * 抛物线运动 
		 * @param display 要移动物体
		 * @param target 目标坐标
		 * @param speed 水平移动速度
		 * @param g 重力
		 * @param callBack 回调函数,到达目标坐标时调用
		 */
		public static function parabola(display:DisplayObject , target:Point , speed:Number = 10, g:Number = 1 , callBack:Function = null):void{
			var distance:Number = Math.abs(target.x - display.x);
			var time:int = distance / speed;
			var spdY:Number = - time / 2 * g;
			
			display.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			
			function onEnterFrame(e:Event):void{
				display.x += speed;
				display.y += spdY;
				spdY += g;
				if(display.x > target.x && display.y > target.y){
					display.removeEventListener(Event.ENTER_FRAME , onEnterFrame);
					if(callBack != null) callBack();
				}
			}
			
		}
	}
}