package net.play5d.kyo.input
{
	import flash.events.Event;
	
	public class KyoTouchEvent extends Event
	{
		public static const SLIDE:String = 'event-slide';
		
		public static const DIRECT_UP:int = 0;
		public static const DIRECT_DOWN:int = 6;
		public static const DIRECT_LEFT:int = 9;
		public static const DIRECT_RIGHT:int = 3;
		
		public var direct:int;
		
		public function KyoTouchEvent(type:String, obj:Object = null)
		{
			for(var i:String in obj){
				this[i] = obj[i];
			}
			super(type, false, false);
		}
	}
}