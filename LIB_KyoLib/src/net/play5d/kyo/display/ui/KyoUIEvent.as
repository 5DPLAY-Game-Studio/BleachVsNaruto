package net.play5d.kyo.display.ui
{
	import flash.events.Event;

	public class KyoUIEvent extends Event
	{
		public static const UPDATE:String = 'event-update';

		public var params:Object;

		public function KyoUIEvent(type:String, params:Object = null)
		{
			super(type, false, false);
			this.params = params;
		}
	}
}
