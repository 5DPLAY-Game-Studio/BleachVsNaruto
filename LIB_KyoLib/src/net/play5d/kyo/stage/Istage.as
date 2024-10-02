package net.play5d.kyo.stage
{
	import flash.display.DisplayObject;

	public interface Istage
	{
		function get display():DisplayObject;
		function build():void;
		function afterBuild():void;
		function destory(back:Function = null):void;
	}
}