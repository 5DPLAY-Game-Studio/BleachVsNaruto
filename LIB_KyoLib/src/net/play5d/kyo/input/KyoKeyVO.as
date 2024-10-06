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

package net.play5d.kyo.input
{
	public class KyoKeyVO
	{
		public function KyoKeyVO(name:String, code:int)
		{
			this.name = name;
			this.code = code;
		}

		public var name:String;
		public var code:int;
		public var isDown:Boolean;

		public function toString():String{
			return name;
		}

		public function clone():KyoKeyVO{
			return new KyoKeyVO(name,code);
		}

	}
}
