package net.play5d.game.bvn.data
{
	//攻击类型 只能添加，不能修改对应的数字
	public class HitType
	{
		public function HitType()
		{
		}
		public static const KAN:int = 1;
		public static const KAN_HEAVY:int = 6;
		
		public static const DA:int = 2;
		public static const DA_HEAVY:int = 3;
		
		public static const MAGIC:int = 4;
		public static const MAGIC_HEAVY:int = 5;
		
		public static const FIRE:int = 7;
		public static const ICE:int = 8;
		public static const ELECTRIC:int = 9;
		public static const STONE:int = 10;
		
		public static const CATCH:int = 11; //抓住
		
		
		private static const heavyTypes:Array = [KAN_HEAVY , DA_HEAVY , MAGIC_HEAVY , FIRE , ICE , ELECTRIC];
		
		public static function isHeavy(v:int):Boolean{
			return heavyTypes.indexOf(v) != -1;
		}
		
	}
}