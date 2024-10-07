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

package net.play5d.game.bvn.fighter.models
{
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class FighterHitModel
	{
		private var _hitObj:Object = {};  //攻击定义
		private var _fighter:IGameSprite;

		public function FighterHitModel(fighter:IGameSprite)
		{
			_fighter = fighter;
		}

		public function destory():void{
			_hitObj = null;
			_fighter = null;
		}

		public function clear():void{
			_hitObj = {};
		}

		public function getHitVO(id:String):HitVO{
			return _hitObj[id];
		}

		public function getAll():Object{
			return _hitObj;
		}

		public function getHitVOLike(likeId:String):Vector.<HitVO>{
			var hv:Vector.<HitVO> = new Vector.<HitVO>();
			for(var i:String in _hitObj){
				if(i.indexOf(likeId) != -1) hv.push(_hitObj[i]);
			}
			return hv;
		}

		/**
		 * 通过MC的名字取HitVO
		 * @param name
		 */
		public function getHitVOByDisplayName(name:String):HitVO{
			var hv:HitVO = getHitVO(name);
			if(hv) return hv;

			if(name.indexOf('atm') == -1) return null;
			var id:String = name.replace('atm','');
			return getHitVO(id);
		}

//		public function isHitAreaDisplay(display:DisplayObject):Boolean{
//			return display.name.indexOf('atm') != -1;
//		}

		/**
		 * 增加HitVO，重复将直接替换
		 * @param id
		 * @param obj
		 *
		 */
		public function addHitVO(id:String , obj:Object):void{
			var hv:HitVO = new HitVO(obj);
			hv.owner = _fighter;
			hv.id = id;
			_hitObj[id] = hv;
		}

		public function setPowerRate(v:Number):void{
			for each(var i:HitVO in _hitObj){
				i.powerRate = v;
			}
		}

	}
}
