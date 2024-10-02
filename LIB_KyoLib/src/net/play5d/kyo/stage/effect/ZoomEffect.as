package net.play5d.kyo.stage.effect
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import net.play5d.kyo.stage.Istage;
	
	public class ZoomEffect implements IStageFadEffect
	{
		private var _duration:Number;
		private var _back:Boolean;
		private var _fixPosition:Boolean;
		public function ZoomEffect(duration:Number = 0.3 , back:Boolean = true)
		{
			_duration = duration;
			_back = back;
		}
		
		public function fadIn(stage:Istage, complete:Function=null):void
		{
			var z:Number = 0.5;
			var p:Point = new Point();
			var d:DisplayObject = stage.display;
			p.x = d.x + d.width * z / 2;
			p.y = d.y + d.height * z / 2;
			
			var to:Object = {scaleX:z,scaleY:z,x:p.x,y:p.y,onComplete:complete};
			if(_back){
				to['ease'] = Back.easeOut;
			}
			TweenLite.from(stage.display,_duration,to);
		}
		
		public function fadOut(stage:Istage, complete:Function=null):void
		{
			var z:Number = 0.1;
			var p:Point = new Point();
			var d:DisplayObject = stage.display;
			p.x = d.x + d.width / 2 - d.width * z;
			p.y = d.y + d.height / 2 - d.height * z;
			TweenLite.to(stage.display,_duration,{scaleX:z,scaleY:z,x:p.x,y:p.y,onComplete:complete});
		}
	}
}