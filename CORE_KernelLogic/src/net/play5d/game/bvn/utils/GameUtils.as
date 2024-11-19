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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class GameUtils
	{
		include "_INCLUDE_.as";

		public static function isInTop(child:DisplayObject,container:DisplayObjectContainer = null,globalPoint:Point = null):Boolean
		{
			if(!container)
			{
				container = child.stage;
			}
			if(!globalPoint)
			{
				globalPoint = new Point(1,1);
				try
				{
					globalPoint.x = container.stage.stageWidth / 2;
					globalPoint.y = container.stage.stageHeight / 2;
				}
				catch(err)
				{
				}
			}
			var arr:Array = container.getObjectsUnderPoint(globalPoint);
			if(arr && arr.length > 0)
			{
				var top:DisplayObject = arr.pop();
				if(child is DisplayObjectContainer)
				{
					var dc:DisplayObjectContainer = child as DisplayObjectContainer;
					return dc.contains(top);
				}
				else
				{
					return top == child;
				}
			}
			return false;
		}


	}
}
