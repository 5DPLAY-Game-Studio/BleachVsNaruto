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

package net.play5d.game.bvn.debug
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.utils.DebugSprite;

	public class DebugUtil
	{
		include "_INCLUDE_.as";

		private static const map:Dictionary = new Dictionary();

		public static const enabled:Boolean = true;

		public static function debugPosition(d:DisplayObject, container:DisplayObjectContainer = null):void{
			if(!enabled) return;

			if(map[d]){
				(map[d] as DebugSprite).destory();
			}

			if(!d.parent && !container){
				trace("debugPosition 失败");
				return;
			}

			container ||= d.parent;

			var box:DebugSprite = new DebugSprite(0xffff00, d);
			box.alpha = 0.3;
			container.addChild(box);

			box.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);

			map[d] = box;

			function startDrag(e:MouseEvent):void{
				var t:DebugSprite = e.currentTarget as DebugSprite;
				if(t.parent) t.parent.addChild(t);

				t.alpha = 0.7;
				t.startDrag(false);
				t.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
			}

			function stopDrag(e:MouseEvent):void{
				var t:DebugSprite = e.currentTarget as DebugSprite;
				t.alpha = 0.1;

				t.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);

				t.stopDrag();
				t.applySet();
			}

		}

	}
}
