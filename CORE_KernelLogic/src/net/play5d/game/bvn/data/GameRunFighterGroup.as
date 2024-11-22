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
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class GameRunFighterGroup
	{
		include '../../../../../../include/_INCLUDE_.as';

		public var fighter1:FighterVO;
		public var fighter2:FighterVO;
		public var fighter3:FighterVO;

		public var assister:FighterVO;

		public var currentFighter:FighterMain;
		public var currentAssister:Assister;

		private var _fighterMap:Dictionary;

		public function GameRunFighterGroup()
		{
		}

		public function destory():void{
			fighter1 = null;
			fighter2 = null;
			fighter3 = null;
			assister = null;

			if(currentFighter){
				currentFighter.destory(true);
				currentFighter = null;
			}
			if(currentAssister){
				currentAssister.destory(true);
				currentAssister = null;
			}
		}

		public function getFighters(exceptCurrentFighter:Boolean = false):Vector.<FighterVO>{
			var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
			var curData:FighterVO = currentFighter ? currentFighter.data : null;
			if(exceptCurrentFighter){
				if(fighter1 != curData) vec.push(fighter1);
				if(fighter2 != curData) vec.push(fighter2);
				if(fighter3 != curData) vec.push(fighter3);
			}else{
				vec.push(fighter1);
				vec.push(fighter2);
				vec.push(fighter3);
			}
			return vec;
		}

		public function getAliveFighters():Vector.<FighterMain>{
			var vec:Vector.<FighterMain> = new Vector.<FighterMain>();

			var f1:FighterMain = getFighter(fighter1);
			var f2:FighterMain = getFighter(fighter2);
			var f3:FighterMain = getFighter(fighter3);

			if(f1 && f1.isAlive) vec.push(f1);
			if(f2 && f2.isAlive) vec.push(f2);
			if(f3 && f3.isAlive) vec.push(f3);
			return vec;
		}

		public function getNextAliveFighter():FighterMain{
			if(!currentFighter) return null;

			var aliveFighters:Vector.<FighterMain> = getAliveFighters();
			if(aliveFighters.length < 2) return null;

			var index:int = aliveFighters.indexOf(currentFighter);
			if(index == aliveFighters.length - 1){
				return aliveFighters[0];
			}

			return aliveFighters[index+1];
		}

		public function getNextFighter(loop:Boolean = false):FighterVO{
			if(!currentFighter) return null;
			switch(currentFighter.data){
				case fighter1:
					return fighter2;
				case fighter2:
					return fighter3;
				case fighter3:
					return loop ? fighter1 : null;
			}
			return null;
		}

		public function putFighter(f:FighterMain):void{
			_fighterMap ||= new Dictionary();
			_fighterMap[f.data] = f;
		}

		public function getFighter(data:FighterVO):FighterMain{
			if(!_fighterMap) return null;
			return _fighterMap[data];
		}

		public function getHoldFighters():Vector.<FighterMain>{
			if(!currentFighter) return null;

			var aliveFighters:Vector.<FighterMain> = getAliveFighters();
			var index:int = aliveFighters.indexOf(currentFighter);
			if(index != -1){
				aliveFighters.splice(index, 1);
			}

			return aliveFighters;
		}

	}
}
