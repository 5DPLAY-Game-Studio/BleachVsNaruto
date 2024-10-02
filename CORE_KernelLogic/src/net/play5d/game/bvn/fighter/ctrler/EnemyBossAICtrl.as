package net.play5d.game.bvn.fighter.ctrler
{
	public class EnemyBossAICtrl extends FighterAICtrl
	{
		public function EnemyBossAICtrl()
		{
			super();
		}
		
		public override function waiKai():Boolean
		{
			return false;
		}
		public override function waiKaiW():Boolean
		{
			return false;
		}
		public override function waiKaiS():Boolean
		{
			return false;
		}
		
		public override function ghostStep():Boolean{
			return false;
		}
		public override function ghostJump():Boolean{
			return false;
		}
		public override function ghostJumpDown():Boolean{
			return false;
		}
		
		public override function assist():Boolean
		{
			return false;
		}
		
		public override function specailSkill():Boolean
		{
			return false;
		}
		
		public override function bishaSUPER():Boolean
		{
			return false;
		}
		
		public override function catch1():Boolean
		{
			return false;
		}
		
		public override function catch2():Boolean
		{
			return false;
		}
		
	}
}