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

package net.play5d.game.bvn.data.mosou.player
{
	import net.play5d.game.bvn.data.ISaveData;

	public class MosouWorldMapAreaPlayerVO implements ISaveData
	{
		include "_INCLUDE_.as";

		public var id:String;
		public var name:String;

//		public var missions:Vector.<MosouMissionPlayerVO> = new Vector.<MosouMissionPlayerVO>();

		private var _passedMissions:Vector.<MosouMissionPlayerVO> = new Vector.<MosouMissionPlayerVO>();

//		public var isOpen:Boolean;

		public function MosouWorldMapAreaPlayerVO()
		{
		}

		public function passMission(missionId:String, starts:int = 1):Boolean{
			var isNewPassed:Boolean = false;

			var mv:MosouMissionPlayerVO = getPassedMission(missionId);
			if(!mv){
				isNewPassed = true;
				mv = new MosouMissionPlayerVO();
				mv.id = missionId;
				_passedMissions.push(mv);
			}

			mv.stars = starts;

			return isNewPassed;
		}


		public function getPassedMission(id:String):MosouMissionPlayerVO{
			for(var i:int; i < _passedMissions.length; i++){
				if(_passedMissions[i].id == id) return _passedMissions[i];
			}
			return null;
		}

		public function getLastPassedMission():MosouMissionPlayerVO{
			if(_passedMissions.length < 1) return null;
			return _passedMissions[_passedMissions.length - 1];
		}

		public function getPassedMissionAmount():int{
			return _passedMissions.length;
		}

		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;
			o.name = name;

			o.missions = [];
			for(var i:int; i < _passedMissions.length; i++){
				o.missions.push(_passedMissions[i].toSaveObj());
			}
			return o;
		}

		public function readSaveObj(o:Object):void
		{
			id = o.id;
			name = o.name;

			_passedMissions = new Vector.<MosouMissionPlayerVO>();
			if(o.missions){
				for(var i:int; i < o.missions.length; i++){
					var mv:MosouMissionPlayerVO = new MosouMissionPlayerVO();
					mv.readSaveObj(o.missions[i]);
					_passedMissions.push(mv);
				}
			}

		}
	}
}
