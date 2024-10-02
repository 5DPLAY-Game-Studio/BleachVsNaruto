package net.play5d.kyo.display.ui
{
	import flash.events.Event;
	
	public class IphoneIconListEvent extends Event
	{
		public static const PAGE_CHANGE:String = 'PAGE_CHANGE';
		public function IphoneIconListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}