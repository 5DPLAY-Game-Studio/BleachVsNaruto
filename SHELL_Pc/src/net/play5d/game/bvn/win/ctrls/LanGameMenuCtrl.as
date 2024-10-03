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

package net.play5d.game.bvn.win.ctrls
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.KeyBoarder;
	import net.play5d.game.bvn.win.views.lan.LANExitDialog;

	public class LanGameMenuCtrl
	{

		private static var _i:LanGameMenuCtrl;

		public static function get I():LanGameMenuCtrl{
			_i ||= new LanGameMenuCtrl();
			return _i;
		}

		private var _isKeyDown:Boolean;

		private var _exitDialog:LANExitDialog;

		public function LanGameMenuCtrl()
		{
		}

		public function init():void{

			_exitDialog = new LANExitDialog();
			_exitDialog.hide();
			KeyBoarder.listen(keyHandler);
		}

		public function dispose():void{
			if(_exitDialog){
				try{
					MainGame.I.root.removeChild(_exitDialog);
				}catch(e:Error){
					trace(e);
				}
				_exitDialog.destory();
				_exitDialog = null;
			}

			KeyBoarder.unListen(keyHandler);

			_isKeyDown = false;

		}

		private function keyHandler(e:KeyboardEvent):void{

			if(e.type == KeyboardEvent.KEY_DOWN){
				if(_isKeyDown) return;
				if(!_exitDialog) return;
				if(e.keyCode == Keyboard.ESCAPE){
					_isKeyDown = true;
					if(_exitDialog.isShowing()){
						_exitDialog.hide();
					}else{
						MainGame.I.root.addChild(_exitDialog);
						_exitDialog.show();
					}
				}
			}

			if(e.type == KeyboardEvent.KEY_UP){
				if(e.keyCode == Keyboard.ESCAPE){
					_isKeyDown = false;
				}
			}

		}

	}
}
