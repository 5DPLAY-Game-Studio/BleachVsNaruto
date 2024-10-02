package net.play5d.game.bvn.interfaces
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.data.TeamVO;
	import net.play5d.game.bvn.fighter.models.HitVO;

	public interface IGameSprite
	{
		function destory(dispose:Boolean = true):void;
		function isDestoryed():Boolean; //是否已销毁
		
		function render():void;  //处理逻辑使用，按GameConfig.FPS_MAIN帧率调用
		function renderAnimate():void; //处理动画渲染，按GameConfig.FPS_ANIMATE帧率调用
		
		function getDisplay():DisplayObject;  //返回显示对象
		
		function get direct():int;
		function set direct(value:int):void;
		
		function get x():Number;
		function set x(v:Number):void;
		
		function get y():Number;
		function set y(v:Number):void;
		
//		function get width():Number;
//		function get height():Number;
		
		function get team():TeamVO;  //队伍，同一队伍不可攻击，不能队伍可攻击
		function set team(v:TeamVO):void;
//		function applayG(g:Number):void;
//		function setInAir(v:Boolean):void;
		
		function hit(hitvo:HitVO , target:IGameSprite):void; //攻击到其他人
		function beHit(hitvo:HitVO , hitRect:Rectangle = null):void; //被攻击
		
		function getArea():Rectangle; //返回自身的区域
		function getBodyArea():Rectangle; //返回被打的区域
		function getCurrentHits():Array; //返回当前攻击的区域,[FighterHitVO]
		
		function allowCrossMapXY():Boolean; //是否可穿越地图的XY
		function allowCrossMapBottom():Boolean; //是否可穿越地图的底
		
		function getIsTouchSide():Boolean;
		function setIsTouchSide(v:Boolean):void;
		
		function setSpeedRate(v:Number):void; //速度比例
		
		function setVolume(v:Number):void; //设置音量
		
		function getActive():Boolean; // 是否在场景中
		function setActive(v:Boolean):void; //设置是否在场景中
		
	}
}