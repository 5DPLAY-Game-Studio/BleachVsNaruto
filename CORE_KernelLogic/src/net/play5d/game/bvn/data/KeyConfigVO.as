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
	import net.play5d.kyo.utils.KyoUtils;

	public class KeyConfigVO
	{
		public var id:int;

		public var up:uint;
		public var down:uint;
		public var left:uint;
		public var right:uint;

		public var attack:uint;
		public var jump:uint;
		public var dash:uint;

		public var skill:uint;
		public var superKill:uint; //必杀
		public var beckons:uint; //召唤

		public var selects:Array;

		public function KeyConfigVO(id:int)
		{
			this.id = id;
		}

		public function setKeys(up:uint,down:uint,left:uint,right:uint,attack:uint,jump:uint,dash:uint,skill:uint,superKill:uint,beckons:uint):void{
			this.up = up;
			this.down = down;
			this.left = left;
			this.right = right;
			this.attack = attack;
			this.jump = jump;
			this.dash = dash;
			this.skill = skill;
			this.dash = dash;
			this.superKill = superKill;
			this.beckons = beckons;

			selects ||= [attack];
		}

//		public function getSelectKeyCode():Array{
//			return selects;
//		}

//		public function isSelectKey(code:int):Boolean{
//			return selects.indexOf(code) != -1;
//		}

		public function toSaveObj():Object{
			var o:Object = KyoUtils.itemToObject(this);
			delete o['id'];
			return o;
		}

		public function readSaveObj(o:Object):void{
			KyoUtils.setValueByObject(this,o);
		}

		public function clone():KeyConfigVO{
			var o:Object = toSaveObj();
			var newKey:KeyConfigVO = new KeyConfigVO(id);
			newKey.readSaveObj(o);
			return newKey;
		}

	}
}
