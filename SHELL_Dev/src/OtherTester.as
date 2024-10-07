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

package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;

	import net.play5d.kyo.utils.KyoUtils;

	[SWF(backgroundColor="0")]
	public class OtherTester extends Sprite
	{

		[Embed(source="/test.png")]
		private var testPng:Class;

		public function OtherTester()
		{
			var test:DisplayObject = new testPng();
			test.x = test.y = 100;
//			test.visible = false;
			addChild(test);

			var offset:Point = new Point(10, 10);
//			var filter:GlowFilter = new GlowFilter(0, 1, 10, 10, 2, 1, false, true);
			var filter:GlowFilter = new GlowFilter(0xffffff, 1, offset.x, offset.y, 1.5, 1, false, true);
			var bd:BitmapData = KyoUtils.drawBitmapFilter(test, filter , true, offset);
			var bp:Bitmap = new Bitmap(bd);

			addChild(bp);

			bp.x = test.x - offset.x;
			bp.y = test.y - offset.y;

		}
	}
}
