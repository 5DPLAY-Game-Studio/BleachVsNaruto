package net.play5d.kyo.display.ui
{
	import flash.events.IEventDispatcher;

	public interface IKyoScrollBar extends IEventDispatcher
	{
		function update(pos:Number):void;
		function set enabled(v:Boolean):void;
	}
}