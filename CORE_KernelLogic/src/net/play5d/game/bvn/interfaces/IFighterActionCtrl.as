package net.play5d.game.bvn.interfaces
{
	public interface IFighterActionCtrl
	{
		function initlize():void;
		
		function render():void;
		function renderAnimate():void;
		
		function destory():void;
		
		function enabled():Boolean;
//		function setEnabled(v:Boolean):void;
		
		function moveLEFT():Boolean;
		function moveRIGHT():Boolean;
		
		function defense():Boolean;
		
		function attack():Boolean;
		function jump():Boolean;
		function jumpQuick():Boolean;
		function jumpDown():Boolean; //从空中的板下来
		function dash():Boolean;
		
		function dashJump():Boolean; //倒地起身
		
		function skill1():Boolean;
		function skill2():Boolean;
		
		function zhao1():Boolean;
		function zhao2():Boolean;
		function zhao3():Boolean;
		
		function catch1():Boolean;
		function catch2():Boolean;
		
		function bisha():Boolean;
		function bishaUP():Boolean;
		function bishaSUPER():Boolean;
		
		function assist():Boolean;
		function specailSkill():Boolean;
		
		function attackAIR():Boolean;
		function skillAIR():Boolean;
		function bishaAIR():Boolean;
		
		function waiKai():Boolean;
		function waiKaiW():Boolean;
		function waiKaiS():Boolean;
		
		function ghostStep():Boolean;
		function ghostJump():Boolean;
		function ghostJumpDown():Boolean;
	}
}