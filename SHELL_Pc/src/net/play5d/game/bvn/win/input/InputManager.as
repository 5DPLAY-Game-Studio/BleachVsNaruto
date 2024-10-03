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

package net.play5d.game.bvn.win.input
{
	import net.play5d.game.bvn.input.GameKeyInput;

	public class InputManager
	{

		private static var _i:InputManager;

		public static function get I():InputManager{
			_i ||= new InputManager();
			return _i;
		}

		public var key_menu:GameKeyInput = new GameKeyInput();
		public var key_p1:GameKeyInput = new GameKeyInput();
		public var key_p2:GameKeyInput = new GameKeyInput();

		public var joy_menu:GameJoystickInput = new GameJoystickInput(1);
		public var joy_p1:GameJoystickInput = new GameJoystickInput(1);
		public var joy_p2:GameJoystickInput = new GameJoystickInput(2);

//		public var socket_input_menu:GameSocketInput = new GameSocketInput();
		public var socket_input_p1:GameSocketInput = new GameSocketInput();
		public var socket_input_p2:GameSocketInput = new GameSocketInput();

//		public const defaultConfig:JoyStickConfigVO = new JoyStickConfigVO();


		public function InputManager()
		{
		}

//		public function updateSetting():void{
//			joy_menu.setDeviceId(joy_p1.getDeviceId());
//		}
	}
}
