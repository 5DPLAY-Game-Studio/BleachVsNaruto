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

package net.play5d.game.bvn.ui
{
	import flash.filters.DropShadowFilter;

	import net.play5d.kyo.display.BitmapText;

	public class Text extends BitmapText
	{
		include '../../../../../../include/_INCLUDE_.as';

		public function Text(color:uint = 0xffffff, size:int = 20)
		{
			super(true, color, [new DropShadowFilter()]);

			font = "Arial";
			fontSize = size;

		}

		public override function get textWidth():Number{
			return _tf.textWidth;
		}

		public override function get textHeight():Number{
			return _tf.textHeight;
		}


	}
}
