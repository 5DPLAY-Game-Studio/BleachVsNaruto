package net.play5d.kyo.stage.effect
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	
	import net.play5d.kyo.stage.Istage;
	
	public class ElastEffect implements IStageFadEffect
	{
		private var _duration:Number;
		public function ElastEffect(duration:Number = 1)
		{
			_duration = duration;
		}
		
		public function fadIn(stage:Istage, complete:Function=null):void
		{
			TweenLite.from(stage.display,_duration,{y:-stage.display.height,ease:Elastic.easeOut});
		}
		
		public function fadOut(stage:Istage, complete:Function=null):void
		{
			TweenLite.to(stage.display,_duration,{y:-stage.display.height,ease:Elastic.easeOut});
		}
	}
}