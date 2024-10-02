package net.play5d.game.bvn.utils
{
	import flash.events.Event;

	public class TouchMoveEvent extends Event
	{
		public static const TOUCH_BEGIN:String = "EVENT_TOUCH_BEGIN";
		public static const TOUCH_MOVE:String = "EVENT_TOUCH_MOVE";
		public static const TOUCH_END:String = "EVENT_TOUCH_END";
		
		public var deltaX:Number;
		public var deltaY:Number;
		
		public var delta:Number;
		
		public var startX:Number = 0;
		public var startY:Number = 0;
		
		public var endX:Number = 0;
		public var endY:Number = 0;
		
		public var distanceX:Number = 0; // 从触摸开始到结束的X距离
		public var distanceY:Number = 0; // 从触摸开始到结束的Y距离
		
		public function TouchMoveEvent(type:String)
		{
			super(type, false, false);
		}
	}
}