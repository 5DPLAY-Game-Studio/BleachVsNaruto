package net.play5d.game.bvn.data.mosou
{
	public class LevelModel
	{
		public function LevelModel()
		{
		}
		
		/**
		 * 角色升级需要的经验值 
		 */
		public static function getLevelUpExp(level:int):int{
			if(level <= 0) return 0;
			
			function solveExp(level:int):int{
				var n:int = level;
				var exp:int = ((3.8 * n * n) - ( 1.2 * n )) + 48.6;
				return exp;
			}
			
			var exp:int = solveExp(level);
			
			if(level > 1){
				for(var i:int = 1 ; i < level ; i++){
					exp += solveExp(i);
				}
			}
			
			return exp;
		}
		
	}
}