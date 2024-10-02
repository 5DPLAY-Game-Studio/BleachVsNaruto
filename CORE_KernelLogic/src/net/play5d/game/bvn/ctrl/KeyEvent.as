package net.play5d.game.bvn.ctrl
{
	import flash.events.Event;
	
	public class KeyEvent extends Event
	{
		public static const KEY_DOWN:String = 'KEY_DOWN';
		public static const KEY_UP:String = 'KEY_UP';
		
		public var keyCode:uint;
		public var justDown:Boolean;
		public function KeyEvent(type:String, keyCode:uint, justDown:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.keyCode = keyCode;
			this.justDown = justDown;
			super(type, bubbles, cancelable);
		}
	}
}