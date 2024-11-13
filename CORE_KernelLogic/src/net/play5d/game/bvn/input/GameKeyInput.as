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

package net.play5d.game.bvn.input
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.data.KeyConfigVO;
	import net.play5d.game.bvn.utils.KeyBoarder;

	public class GameKeyInput implements IGameInput
	{
		include "_INCLUDE_.as";

		private var _config:KeyConfigVO;
		private var _downKeys:Object = {};
		private var _enabled:Boolean = true;

		public function GameKeyInput()
		{
		}

		public function initlize(stage:Stage):void{
			KeyBoarder.initlize(stage);
			KeyBoarder.listen(keyBoardHandler);
		}

		public function get enabled():Boolean{
			return _enabled;
		}

		public function set enabled(v:Boolean):void{
			_enabled = v;
		}

		public function setConfig(config:Object):void{
			_config = config as KeyConfigVO;
		}

		public function focus():void{
			KeyBoarder.focus();
		}

		public function anyKey():Boolean{
			for(var i:String in _downKeys){
				if(_downKeys[i] == 1) return true;
			}
			return false;
		}


		public function back():Boolean
		{
			return isDown(Keyboard.ESCAPE);
		}

		public function select():Boolean
		{
			for each(var i:int in _config.selects){
				if(isDown(i)) return true;
			}
			return false;
		}

		public function up():Boolean
		{
			return isDown(_config.up);
		}

		public function down():Boolean
		{
			return isDown(_config.down);
		}

		public function left():Boolean
		{
			return isDown(_config.left);
		}

		public function right():Boolean
		{
			return isDown(_config.right);
		}

		public function attack():Boolean{
			return isDown(_config.attack);
		}

		public function jump():Boolean{
			return isDown(_config.jump);
		}

		public function dash():Boolean{
			return isDown(_config.dash);
		}

		public function skill():Boolean{
			return isDown(_config.skill);
		}

		public function superSkill():Boolean{
			return isDown(_config.superKill);
		}

		public function special():Boolean{
			return isDown(_config.beckons);
		}

		public function wankai():Boolean{
			return isDown(_config.attack) && isDown(_config.jump);
		}

		public function clear():void
		{
			_downKeys = {};
		}



		private function keyBoardHandler(e:KeyboardEvent):void{
			switch(e.type){
				case KeyboardEvent.KEY_DOWN:
					_downKeys[e.keyCode] = 1;
					break;
				case KeyboardEvent.KEY_UP:
					_downKeys[e.keyCode] = 0;
					break;
			}
		}

		private function isDown(keycode:uint):Boolean{
			return _downKeys[keycode] == 1;
		}

	}
}
