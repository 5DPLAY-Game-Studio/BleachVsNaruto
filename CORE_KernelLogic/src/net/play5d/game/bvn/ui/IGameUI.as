package net.play5d.game.bvn.ui
{
	import flash.display.DisplayObject;

	public interface IGameUI
	{
		function setVolume(v:Number):void;
		function destory():void;
		function fadIn(animate:Boolean = true):void;
		function fadOut(animate:Boolean = true):void;
		function getUI():DisplayObject;
		function render():void;
		function renderAnimate():void;
		function showHits(hits:int , id:int):void;
		function hideHits(id:int):void;
		function showStart(finishBack:Function = null , params:Object = null):void;
		function showEnd(finishBack:Function = null , params:Object = null):void;
		function clearStartAndEnd():void;
		function pause():void;
		function resume():Boolean;
	}
}