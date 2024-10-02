package net.play5d.kyo.stage.effect
{
	import com.greensock.TweenLite;

	import flash.geom.Point;

	import net.play5d.kyo.stage.Istage;

	public class StageFadEffectOrg implements IStageFadEffect
	{
		private var _obj:Object;
		private var _time:Number;
		public function StageFadEffectOrg(time:Number = 0.5, x:Boolean = false, y:Boolean = false, alpha:Boolean = false, easefun:Function = null)
		{
			_time = time;
			_obj = {};
			_obj.x = x;
			_obj.y = y;
			_obj.alpha = alpha;
			_obj.easefun = easefun;
		}

		public function fadIn(stage:Istage,complete:Function = null):void
		{
			var to:Object = {};
			if(_obj.x){
				to.x = stage.display.x;
				stage.display.x = 0;
			}
			if(_obj.y){
				to.y = stage.display.y;
				stage.display.y = 0;
			}
			if(_obj.alpha){
				to.alpha = stage.display.alpha;
				stage.display.alpha = 0;
			}
			if(_obj.easefun){
				to.ease = _obj.easefun;
			}
			if(complete != null){
				to.onComplete = complete;
			}
			TweenLite.to(stage.display,_time,to);
		}

		public function fadOut(stage:Istage,complete:Function = null):void
		{
		}
	}
}
