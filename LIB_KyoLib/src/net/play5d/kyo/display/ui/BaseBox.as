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

package net.play5d.kyo.display.ui
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class BaseBox extends Sprite
	{
		public var gapX:Number;
		public var gapY:Number;

		protected var _instances:Array;

		private var _repeater:KyoRepeater;

		public final function get repeater():KyoRepeater
		{
			return _repeater;
		}

		public final function set repeater(value:KyoRepeater):void
		{
			_repeater = value;
			buildByRepeater();
		}

		protected function build():void{}

		protected function buildByRepeater():void{}

		public final function get instances():Array{
			return _instances;
		}

		public final function set instances(v:Array):void{
			_instances = v;
			build();
		}

		public function BaseBox()
		{
		}

		public function removeAll(e:Event):void{
			for(var i:String in _instances)delete _instances[i];
			_instances = null;
		}
	}
}
