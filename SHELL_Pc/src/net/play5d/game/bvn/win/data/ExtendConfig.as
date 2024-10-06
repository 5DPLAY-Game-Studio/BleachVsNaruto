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

package net.play5d.game.bvn.win.data
{
	import net.play5d.game.bvn.interfaces.IExtendConfig;
	import net.play5d.game.bvn.win.input.JoyStickConfigVO;
	import net.play5d.game.bvn.win.input.JoySticker;

	public class ExtendConfig implements IExtendConfig
	{

		public var joyMenuConfig:JoyStickConfigVO = new JoyStickConfigVO();
		public var joy1Config:JoyStickConfigVO = new JoyStickConfigVO();
		public var joy2Config:JoyStickConfigVO = new JoyStickConfigVO();

		public var isFullScreen:Boolean = false;

		private var _isInitDefaultJoystick:Boolean;

		public function ExtendConfig()
		{
		}

		public function toSaveObj():Object{
			var o:Object = {};
			o.joy_menu = joyMenuConfig.toObj();
			o.joy_p1 = joy1Config.toObj();
			o.joy_p2 = joy2Config.toObj();
			o.isFullScreen = isFullScreen;
			o.lan_name = LanGameModel.I.playerName;
			return o;
		}

		public function readSaveObj(obj:Object):void{
			if(!obj) return;
			joyMenuConfig.readObj(obj.joy_menu);
			joy1Config.readObj(obj.joy_p1);
			joy2Config.readObj(obj.joy_p2);
			isFullScreen = obj.isFullScreen;
			updateJoyConfig();

			if(obj.lan_name) LanGameModel.I.playerName = obj.lan_name;

		}

		public function updateJoyConfig():void{
			initDefaultDevices();
			joyMenuConfig.deviceId = joy1Config.deviceId;
		}

		private function initDefaultDevices():void{
			if(_isInitDefaultJoystick) return;

			trace('initDefaultDevices');

			_isInitDefaultJoystick = true;

			setDefaultDevice(joy1Config , 0);
			setDefaultDevice(joy2Config , 1);
		}

		private function setDefaultDevice(joy:JoyStickConfigVO , index:int):void{
			if(!joy.deviceIsSet && joy.deviceId == null) joy.deviceId = JoySticker.getDeviceId(index);
		}

	}
}
