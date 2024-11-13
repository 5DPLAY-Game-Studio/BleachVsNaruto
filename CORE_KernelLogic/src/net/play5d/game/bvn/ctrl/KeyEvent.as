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

package net.play5d.game.bvn.ctrl
{
	import flash.events.Event;

	public class KeyEvent extends Event
	{
		include "_INCLUDE_.as";

		public static const KEY_DOWN:String = 'KEY_DOWN';
		public static const KEY_UP:String = 'KEY_UP';

		public var keyCode:uint;
		public var justDown:Boolean;
		public function KeyEvent(type:String, keyCode:uint, justDown:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.keyCode = keyCode;
			this.justDown = justDown;
			super(type, bubbles, cancelable);
		}
	}
}
