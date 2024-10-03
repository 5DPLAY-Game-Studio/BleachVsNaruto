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
	import flash.display.Stage;

	import net.play5d.game.bvn.input.IGameInput;

	public class GameJoystickInput implements IGameInput
	{
		public var player:int;

		private var _config:JoyStickConfigVO;

		private var _enabled:Boolean = true;

		public function GameJoystickInput(player:int)
		{
			this.player = player;
		}

		public function get enabled():Boolean{
			return _enabled;
		}

		public function set enabled(v:Boolean):void{
			_enabled = v;
		}

		public function getDeviceId():String{
			return _config.deviceId;
		}

		public function setDeviceId(id:String):void{
			_config.deviceId = id;
		}

		public function initlize(stage:Stage):void
		{
			JoySticker.initlize();
		}

		public function setConfig(config:Object):void
		{
			this._config = config as JoyStickConfigVO;
		}

		public function focus():void
		{
		}

		public function anyKey():Boolean
		{
			return JoySticker.isDownAnyKey(_config.deviceId);
		}

		public function back():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.back) || JoySticker.isDown(_config.deviceId , _config.select);
		}

		public function select():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.jump);
		}

		public function up():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.up) || JoySticker.isDown(_config.deviceId , _config.up2);
		}

		public function down():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.down) || JoySticker.isDown(_config.deviceId , _config.down2);
		}

		public function left():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.left) || JoySticker.isDown(_config.deviceId , _config.left2);
		}

		public function right():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.right) || JoySticker.isDown(_config.deviceId , _config.right2);
		}

		public function attack():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.attack);
		}

		public function jump():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.jump);
		}

		public function dash():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.dash);
		}

		public function skill():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.skill);
		}

		public function superSkill():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.superSkill);
		}

		public function special():Boolean
		{
			return JoySticker.isDown(_config.deviceId , _config.special);
		}

		public function wankai():Boolean{
			return JoySticker.isDown(_config.deviceId , _config.waikai);
		}

		public function clear():void
		{
		}
	}
}
