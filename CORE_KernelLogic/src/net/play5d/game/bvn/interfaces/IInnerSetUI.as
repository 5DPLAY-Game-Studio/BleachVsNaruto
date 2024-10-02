package net.play5d.game.bvn.interfaces
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	public interface IInnerSetUI extends IEventDispatcher
	{
		function fadIn():void;
		function fadOut():void;
		function getUI():DisplayObject;
		function destory():void;
	}
}