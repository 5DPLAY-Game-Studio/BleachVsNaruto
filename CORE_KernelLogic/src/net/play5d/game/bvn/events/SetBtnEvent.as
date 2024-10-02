package net.play5d.game.bvn.events
{
	import flash.events.Event;
	
	public class SetBtnEvent extends Event
	{
		public static const SELECT:String = 'SELECT';
		public static const OPTION_CHANGE:String = 'OPTION_CHANGE';
		public static const APPLY_SET:String = 'APPLY_SET';
		public static const CANCEL_SET:String = 'CANCEL_SET';
		
		public var selectedLabel:String;
		
		public var optionKey:String;
		public var optionValue:*;
		
		public function SetBtnEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function newEvent():SetBtnEvent{
			var event:SetBtnEvent = new SetBtnEvent(type,bubbles,cancelable);
			event.selectedLabel = selectedLabel;
			event.optionKey = optionKey;
			event.optionValue = optionValue;
			return event;
		}
		
	}
}