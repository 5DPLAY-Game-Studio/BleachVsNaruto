package net.play5d.game.bvn.data
{
	import net.play5d.game.bvn.ctrl.GameLogic;

	public class MessionModel
	{
		private static var _i:MessionModel;
		
		public static function get I():MessionModel{
			_i ||= new MessionModel();
			return _i;
		}
		
		public var AI_LEVEL:int = 3;  //1-6
		
		private var _curMession:MessionVO;  //当前关卡
		private var _curStageId:int;  //当前关卡ID
		private var _curStage:MessionStageVO;  //当前关卡
		private var _messions:Array;
		
		public function MessionModel()
		{
		}
		
		public function getAllMissions():Array{
			return _messions;
		}
		
		public function initByXML(xml:XML):void{
			_messions = [];
			
			for each(var i:XML in xml.design){
				var mv:MessionVO = new MessionVO();
				mv.initByXML(i);
				_messions.push(mv);
			}
		}
		
		/**
		 * 获取关卡数据
		 * @param comicType 0=死神，1=火影
		 * @param gameMode 0=team，1=single
		 */
		public function getMession(comicType:int , gameMode:int):MessionVO{
			for each(var i:MessionVO in _messions){
				if(i.comicType == comicType && i.gameMode == gameMode){
					return i;
				}
			}
			return null;
		}
		
		public function getCurrentMessionStage():MessionStageVO{
			return _curStage;
		}
		
		public function initMession():void{
			var fighter:FighterVO = FighterModel.I.getFighter(GameData.I.p1Select.fighter1);
			var gameMode:int = GameMode.isTeamMode() ? 0 : 1;
			var mv:MessionVO = getMession(fighter.comicType , gameMode);
			_curMession = mv;
			_curStage = mv.stageList[_curStageId];
			
			GameData.I.p2Select ||= new SelectVO();
			
			var fighters:Array = _curStage.getFighters();
			
			for(var i:int ; i < fighters.length ; i++){
				GameData.I.p2Select['fighter'+(i+1)] = fighters[i];
			}
			GameData.I.p2Select.fuzhu = _curStage.assister;
			GameData.I.selectMap = _curStage.map;
			
			
			AI_LEVEL = GameData.I.config.AI_level;
			
			trace('p1::',GameData.I.p1Select.toString());
			trace('p2::',GameData.I.p2Select.toString());
			
			
			
		}
		
		public function reset():void{
			_curStageId = 0;
			_curStage = null;
			_curMession = null;
			GameData.I.score = 0;
		}
		
		public function messionComplete():void{
			if(missionAllComplete()){
				trace('mission all over!!!');
				return;
			}
			
			_curStageId++;
			
			initMession();
			
			if(GameMode.isAcrade()) GameLogic.addScoreByPassMission();
		}
		
		public function missionAllComplete():Boolean{
			return _curStageId >= _curMession.stageList.length-1;
		}
		
		
	}
}