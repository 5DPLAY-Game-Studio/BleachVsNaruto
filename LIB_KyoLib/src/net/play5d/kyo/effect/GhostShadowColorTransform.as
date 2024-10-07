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

package net.play5d.kyo.effect
{
	import flash.geom.ColorTransform;

	public class GhostShadowColorTransform
	{
		public function GhostShadowColorTransform()
		{
		}

		private static var _red:ColorTransform;
		public static function get red():ColorTransform{
			if(!_red){
				_red = new ColorTransform();
				_red.redOffset = 255;
			}
			return _red;
		}

		private static var _blue:ColorTransform;
		public static function get blue():ColorTransform{
			if(!_blue){
				_blue = new ColorTransform();
				_blue.blueOffset = 255;
			}
			return _blue;
		}
	}
}
