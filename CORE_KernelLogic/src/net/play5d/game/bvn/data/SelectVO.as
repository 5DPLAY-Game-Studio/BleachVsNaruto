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
	public class SelectVO
	{
		include '../../../../../../include/_INCLUDE_.as';

//		选中的人物ID
		public var fighter1:String;
		public var fighter2:String;
		public var fighter3:String;
		public var fuzhu:String;

		public function getSelectFighters():Array{
			var a:Array = [];
			if(fighter1) a.push(fighter1);
			if(fighter2) a.push(fighter2);
			if(fighter3) a.push(fighter3);
			return a;
		}

		public function isSelected(id:String):Boolean{
			return fighter1 == id || fighter2 == id || fighter3 == id;
		}

		public function toString():String{
			return JSON.stringify(
				{select:{
					fighter1:fighter1,
					fighter2:fighter2,
					fighter3:fighter3,
					fuzhu:fuzhu
				}}
			);
		}

		public function SelectVO()
		{
		}
	}
}
