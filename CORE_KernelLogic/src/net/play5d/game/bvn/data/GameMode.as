package net.play5d.game.bvn.data
{
	/**
	 * 游戏模式 
	 */
	public class GameMode
	{
		public static const TEAM_ACRADE:int = 10;
		public static const TEAM_VS_PEOPLE:int = 11;
		public static const TEAM_VS_CPU:int = 12;
		
		public static const SINGLE_ACRADE:int = 20;
		public static const SINGLE_VS_PEOPLE:int = 21;
		public static const SINGLE_VS_CPU:int = 22;
		
		public static const SURVIVOR:int = 30;
		
		public static const TRAINING:int = 40;
		
		public static const MOSOU_ACRADE:int = 100;
		
//		public static function just1Team():Boolean{
//			return true;
//		}
		
		public static function getTeams():Array{
			return [
				{id:1,name:'P1'},
				{id:2,name:'P2'}
			];
		}
		
		/**
		 * 组队模式 
		 */
		public static function isTeamMode():Boolean{
			return currentMode == TEAM_ACRADE || currentMode == TEAM_VS_CPU || currentMode == TEAM_VS_PEOPLE || currentMode == MOSOU_ACRADE;
		}
		
		/**
		 * 一人模式（经典） 
		 */
		public static function isSingleMode():Boolean{
			return currentMode == SINGLE_ACRADE || currentMode == SINGLE_VS_CPU || currentMode == SINGLE_VS_PEOPLE;
		}
		
		public static function isVsPeople():Boolean{
			return currentMode == TEAM_VS_PEOPLE || currentMode == SINGLE_VS_PEOPLE;
		}
		
		public static function isVsCPU(includeTraining:Boolean = true):Boolean{
			return currentMode == TEAM_VS_CPU || currentMode == SINGLE_VS_CPU || (includeTraining && currentMode == TRAINING);
		}
		
		/**
		 * 过关模式（包括SURVIVOR） 
		 */
		public static function isAcrade():Boolean{
			return currentMode == SINGLE_ACRADE ||  currentMode == TEAM_ACRADE || currentMode == SURVIVOR;
		}
		
		public static var currentMode:int;
		
		public function GameMode()
		{
		}
	}
}