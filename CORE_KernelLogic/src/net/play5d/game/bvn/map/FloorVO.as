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

package net.play5d.game.bvn.map
{
	public class FloorVO
	{
		public var y:Number = 0;
		public var xFrom:Number = 0;
		public var xTo:Number = 0;
		public function FloorVO()
		{
		}

		public function toString():String{
			return "FloorVO::{xFrom:"+xFrom+",xTo:"+xTo+",y:"+y+"}";
		}

		public function hitTest(X:Number , Y:Number , SPEED:Number):Boolean{
			//SPEED = 5
			return Y > y - SPEED && Y < y + SPEED && X > xFrom && X < xTo;
		}

	}
}
