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
	import net.play5d.game.bvn.data.mosou.LevelModel;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.utils.WrapInteger;

	public class MosouFighterVO implements ISaveData
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		public static var LEVEL_MAX:WrapInteger = new WrapInteger(80);

		public var id:String;
		private var _level:WrapInteger = new WrapInteger(0);
		private var _exp:WrapInteger = new WrapInteger(0);

		private var _atk:WrapInteger = new WrapInteger(0);
		private var _skillAtk:WrapInteger = new WrapInteger(0);
		private var _bishaAtk:WrapInteger = new WrapInteger(0);
//		private var _def:WrapInteger = new WrapInteger(0);

		private var _hp:WrapInteger = new WrapInteger(0);
		private var _qi:WrapInteger = new WrapInteger(0);
		private var _energy:WrapInteger = new WrapInteger(0);

//		public var fighterData:FighterVO;

		public function MosouFighterVO()
		{
			_level.setValue(1);
			updateLevel(_level.getValue());
		}

		public function getAttackDmg():int{
			return _atk.getValue();
		}
		public function getSkillDmg():int{
			return _skillAtk.getValue();
		}
		public function getBishaDmg():int{
			return _bishaAtk.getValue();
		}
//		public function getDefense():int{
//			return _def.getValue();
//		}
//		public function getSpeed():int{
//			return _spd.getValue();
//		}
		public function getHP():int{
			return _hp.getValue();
		}
		public function getQI():int{
			return _qi.getValue();
		}
		public function getEnergy():int{
			return _energy.getValue();
		}

		public function getLevel():int{
			return _level.getValue();
		}

		public function getExp():int{
			return _exp.getValue();
		}

		public function addExp(v:int):void{
			var lv:int = _level.getValue();
			var val:int = _exp.getValue() + v;
			var nextExp:int = LevelModel.getLevelUpExp(lv);

//			trace('addExp:: ' + val + '/' + nextExp, '. add', v);

			if(val >= nextExp){
				var isLimit:Boolean = updateLevel(lv + 1);
				if(!isLimit){
					TraceLang('debug.trace.data.musou_fighter_vo.level_up');
					GameEvent.dispatchEvent(GameEvent.LEVEL_UP, this);
					_exp.setValue(val - nextExp);
				}else{
					_exp.setValue(nextExp);
				}
				return;
			}

			_exp.setValue(val);

		}

		private function updateLevel(lv:int):Boolean{
			var lvMax:int = LEVEL_MAX.getValue();
			var isLimit:Boolean = false;

			if(lv < 1) lv = 1;

			if(lv > lvMax){
				lv = lvMax;
				isLimit = true;
			}

			_level.setValue(lv);

			_atk.setValue( lv * 10 );
			_skillAtk.setValue( lv * 15 );
			_bishaAtk.setValue( lv * 17 );

//			_def.setValue( lv * 3 );

			_hp.setValue( 1000 + lv * 150 );
			_energy.setValue( 50 + lv * 10 );

			var qi:int = 100 + lv * 20;
			_qi.setValue( Math.min(qi, 300) );

			return isLimit;
		}


		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;
			o.level = _level.getValue();
			o.exp = _exp.getValue();
			return o;
		}

		public function readSaveObj(o:Object):void
		{
			if(o.id) id = o.id;
			if(o.exp) _exp.setValue(o.exp);
			if(o.level) updateLevel(o.level);
		}

	}
}
