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

package net.play5d.game.bvn.utils
{
	import flash.events.Event;

	public class TouchMoveEvent extends Event
	{
		public static const TOUCH_BEGIN:String = "EVENT_TOUCH_BEGIN";
		public static const TOUCH_MOVE:String = "EVENT_TOUCH_MOVE";
		public static const TOUCH_END:String = "EVENT_TOUCH_END";

		public var deltaX:Number;
		public var deltaY:Number;

		public var delta:Number;

		public var startX:Number = 0;
		public var startY:Number = 0;

		public var endX:Number = 0;
		public var endY:Number = 0;

		public var distanceX:Number = 0; // 从触摸开始到结束的X距离
		public var distanceY:Number = 0; // 从触摸开始到结束的Y距离

		public function TouchMoveEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
