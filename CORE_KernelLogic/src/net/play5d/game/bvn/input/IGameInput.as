package net.play5d.game.bvn.input
{
	import flash.display.Stage;

	public interface IGameInput
	{
		function initlize(stage:Stage):void;
		function setConfig(config:Object):void;
		
		function get enabled():Boolean;
		function set enabled(v:Boolean):void;
		
		function focus():void;
		
		function anyKey():Boolean;
		
		function back():Boolean;
		function select():Boolean;
		
		function up():Boolean;
		function down():Boolean;
		function left():Boolean;
		function right():Boolean;
		
		function attack():Boolean;
		function jump():Boolean;
		function dash():Boolean;
		function skill():Boolean;
		function superSkill():Boolean;
		function special():Boolean;
		
		function wankai():Boolean;
		
//		function isDown(code:Object):Boolean;
//		function isJustDown(code:Object):Boolean;
		
		function clear():void;
		
//		function listen(func:Function):void;
//		function unListen(func:Function):void;
	}
}