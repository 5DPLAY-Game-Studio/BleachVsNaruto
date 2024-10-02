package net.play5d.kyo.display.ui
{
	import flash.events.Event;
	
	public class KyoEvent extends Event
	{
		public static const CHANGE:String = 'kyo-event-change';
		
		public function KyoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}