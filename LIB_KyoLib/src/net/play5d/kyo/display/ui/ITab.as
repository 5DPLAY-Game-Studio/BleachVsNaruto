package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	public interface ITab extends IEventDispatcher
	{
		function get selected():Boolean;
		function set selected(v:Boolean):void;
		function get display():DisplayObject;
	}
}