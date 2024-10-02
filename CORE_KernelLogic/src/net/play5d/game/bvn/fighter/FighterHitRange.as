package net.play5d.game.bvn.fighter
{
	import flash.geom.Rectangle;

	public class FighterHitRange
	{
		public static const JUMP_ATTACK:String = 'tkanmian';
		public static const JUMP_SKILL:String = 'tzmian';
		
		public static const ATTACK:String = 'kanmian';
		
		public static const SKILL1:String = 'kj1mian';
		public static const SKILL2:String = 'kj2mian';
		
		public static const ZHAO1:String = 'zh1mian';
		public static const ZHAO2:String = 'zh2mian';
		public static const ZHAO3:String = 'zh3mian';
		
		public static const BISHA:String = 'bsmian';
		public static const BISHA_AIR:String = 'kbsmian';
		public static const BISHA_UP:String = 'sbsmian';
		public static const BISHA_SUPER:String = 'cbsmian';
		
		public static function getALL():Array{
			return [
				JUMP_ATTACK,JUMP_SKILL,ATTACK,SKILL1,SKILL2,ZHAO1,ZHAO2,ZHAO3,
				BISHA,BISHA_AIR,BISHA_UP,BISHA_SUPER
			];
		}
		
		public function FighterHitRange()
		{
		}
	}
}