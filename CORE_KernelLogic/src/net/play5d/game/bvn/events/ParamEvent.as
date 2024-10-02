package net.play5d.game.bvn.events
{
	import flash.events.Event;
	
	public class ParamEvent extends Event
	{
		public var param:*;
		public function ParamEvent(type:String,param, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.param = param;
			super(type, bubbles, cancelable);
		}
	}
}