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

package net.play5d.kyo.utils
{
	public class ArrayMap
	{
		private var _o:Object;
		private var _arr:Array;
		public function ArrayMap()
		{
			super();
			_o = {};
			_arr = [];
		}

		public function get length():int{
			return _arr.length;
		}

		public function push(id:Object , value:*):void{
			_o[id] = value;
			_arr.push(value);
		}

		public function getItemByIndex(index:int):*{
			return _arr[index];
		}

		public function getItemById(id:Object):*{
			return _o[id];
		}

		public function removeItemById(id:Object):void{
			if(!_o[id]) return;

			var index:int = _arr.indexOf(_o[id]);
			if(index != -1){
				_arr.splice(index, 1);
			}

			delete _o[id];

		}
	}
}
