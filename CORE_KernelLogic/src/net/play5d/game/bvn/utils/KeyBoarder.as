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
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	public class KeyBoarder
	{
		include '../../../../../../include/_INCLUDE_.as';

		private static var _inited:Boolean;

		private static var _stage:Stage;

		private static var _keyHandlers:Vector.<Function> = new Vector.<Function>();

		public function KeyBoarder()
		{
		}

		public static function initlize(stage:Stage):void{
			if(_inited) return;

			_inited = true;

			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyBoardHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyBoardHandler);

		}

		public static function focus():void{
			if(!_inited) return;
			_stage.focus = _stage;
		}

		public static function listen(handler:Function):void{
			if(!_inited) return;
			if(_keyHandlers.indexOf(handler) == -1) _keyHandlers.push(handler);
		}

		public static function unListen(handler:Function):void{
			if(!_inited) return;
			if(_keyHandlers.indexOf(handler) != -1) _keyHandlers.splice( _keyHandlers.indexOf(handler) , 1 );
		}

		private static function keyBoardHandler(e:KeyboardEvent):void{
			if(!_inited) return;
			var i:int = 0;
			for(i = 0 ; i < _keyHandlers.length ; i++){
				_keyHandlers[i](e);
			}
		}

	}
}
