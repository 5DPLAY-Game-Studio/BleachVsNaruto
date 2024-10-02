package net.play5d.kyo.stage.events
{
	import flash.events.Event;
	
	import net.play5d.kyo.stage.Istage;
	
	public class KyoStageEvent extends Event
	{
		
		public static const CHANGE_STATE:String = 'CHANGE_STATE';
		
		public var stage:Istage;
		
		public function KyoStageEvent(type:String, stage:Istage , bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.stage = stage;
		}
	}
}