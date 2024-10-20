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
	public class MessionVO
	{
		public var comicType:int;
		public var gameMode:int;

		public var stageList:Vector.<MessionStageVO>;

		public function MessionVO()
		{
		}

//		public function initByXML(xml:XML):void{
//			comicType = xml.@comicType;
//			gameMode = xml.@gameMode;
//
//			stageList = new Vector.<MessionStageVO>();
//
//			for(var i:int ; i < xml.stage.length() ; i++){
//				var msv:MessionStageVO = new MessionStageVO();
//				var sx:Object = xml.stage[i];
//				var fighter:String = sx.@fighter;
//				msv.mession = this;
//				msv.assister = sx.@assister;
//				msv.fighters = fighter.split(",");
//				msv.map = sx.@map;
//				msv.hpRate = Number(sx.@hpRate) > 0 ? Number(sx.@hpRate) : 1;
//				msv.attackRate = Number(sx.@attackRate) > 0 ? Number(sx.@attackRate) : 1;
//				stageList.push(msv);
//			}
//
//		}

		public function initByObject(obj:Object):void {
			comicType = obj['comic_type'];
			gameMode = obj['game_mode'];

			stageList = new Vector.<MessionStageVO>();

			var stageArr:Array = obj['stage'];
			for each (var stageObj:Object in stageArr) {
				var msv:MessionStageVO = new MessionStageVO();

				msv.mession = this;
				msv.fighters = stageObj['fighter'];
				msv.assister = stageObj['assistant'];
				msv.map = stageObj['map'];

				var propertiesObj:Object = stageObj['properties'];
				if (propertiesObj) {
					if (propertiesObj['attack_rate']) {
						msv.attackRate =
								propertiesObj['attack_rate'] > 0
								? propertiesObj['attack_rate']
								: 1;
					}
					if (propertiesObj['hp_rate']) {
						msv.hpRate =
								propertiesObj['hp_rate'] > 0
								? propertiesObj['hp_rate']
								: 1;
					}
				}

				stageList.push(msv);
			}
		}

	}
}
