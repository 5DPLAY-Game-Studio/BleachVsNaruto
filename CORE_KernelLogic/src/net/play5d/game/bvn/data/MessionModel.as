/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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

		[ArrayElementType ('net.play5d.game.bvn.data.MessionVO')]
		private var _messions:Array;

		public function MessionModel()
		{
		}

		public function getAllMissions():Array{
			return _messions;
		}

//		public function initByXML(xml:XML):void{
//			_messions = [];
//
//			for each(var i:XML in xml.design){
//				var mv:MessionVO = new MessionVO();
//				mv.initByXML(i);
//				_messions.push(mv);
//			}
//		}

		public function initByObject(obj:Object):void {
			_messions = [];

			var levelArr:Array = obj['level'];
			for each(var level:Object in levelArr) {
				var messionVO:MessionVO = new MessionVO();
				messionVO.initByObject(level);

				_messions.push(messionVO);
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

//			trace('p1::',GameData.I.p1Select.toString());
//			trace('p2::',GameData.I.p2Select.toString());

			TraceLang('debug.trace.data.mission_model.p1_data', GameData.I.p1Select);
			TraceLang('debug.trace.data.mission_model.p2_data', GameData.I.p2Select);
		}

		public function reset():void{
			_curStageId = 0;
			_curStage = null;
			_curMession = null;
			GameData.I.score = 0;
		}

		public function messionComplete():void{
			if(missionAllComplete()){
				TraceLang('debug.trace.data.mission_model.mission_all_over');
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
