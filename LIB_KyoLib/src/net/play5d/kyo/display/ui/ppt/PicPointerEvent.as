package net.play5d.kyo.display.ui.ppt
{
	import flash.events.Event;

	public class PicPointerEvent extends Event
	{
		public static const CHANGE_START:String = 'CHANGE_START';
		public static const CHANGE_FINISH:String = 'CHANGE_FINISH';
		public static const MOUSE_UP:String = 'MOUSE_UP';

		public static const LOAD_PROCESS:String = 'LOAD_PROCESS';
		public static const LOAD_COMPLETE:String = 'LOAD_COMPLETE';

		public var data:Object;
		public function PicPointerEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}
	}
}
