package net.play5d.kyo.display.ui
{
	import flash.events.Event;

	public class PicScrollEvent extends Event
	{
		public static const CHANGE:String = 'CHANGE';
		public static const CHANGE_COMPLETE:String = 'CHANGE_COMPLETE';
		public static const MOUSE_UP:String = 'MOUSE_UP';

		public var data:Object;
		public function PicScrollEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}
	}
}
