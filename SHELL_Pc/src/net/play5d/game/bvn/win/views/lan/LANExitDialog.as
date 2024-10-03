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

package net.play5d.game.bvn.win.views.lan
{
	import flash.display.Sprite;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.SetBtnGroup;
	import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;

	public class LANExitDialog extends Sprite
	{
		private var _bg:Sprite;
		private var _btnGroup:SetBtnGroup;

		public function LANExitDialog()
		{
			_bg = new Sprite();
			_bg.graphics.beginFill(0,0.5);
			_bg.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);
			_bg.graphics.endFill();

			addChild(_bg);

			_btnGroup = new SetBtnGroup();
			_btnGroup.setBtnData([
				{label:'CONTINUE',cn:'继续游戏'},
				{label:'EXIT',cn:'退出联机'}
			],0);
			_btnGroup.addEventListener(SetBtnEvent.SELECT,btnGroupSelectHandler);

			if(LANClientCtrl.I.active){
				_btnGroup.gameInputType = GameInputType.P2;
			}

			if(LANServerCtrl.I.active){
				_btnGroup.gameInputType = GameInputType.P1;
			}

			addChild(_btnGroup);
		}

		public function destory():void{
			if(_btnGroup){
				_btnGroup.removeEventListener(SetBtnEvent.SELECT,btnGroupSelectHandler);
				_btnGroup.destory();
				_btnGroup = null;
			}
		}

		public function isShowing():Boolean{
			return visible;
		}

		public function show():void{
			this.visible = true;
			_btnGroup.keyEnable = true;
			_btnGroup.setArrowIndex(0);
		}

		public function hide():void{
			this.visible = false;
			_btnGroup.keyEnable = false;
		}

		private function btnGroupSelectHandler(e:SetBtnEvent):void{
			if(GameUI.showingDialog()) return;
			switch(e.selectedLabel){
				case 'EXIT':
					if(LANServerCtrl.I.active){
						LANServerCtrl.I.gameQuit();
					}
					if(LANClientCtrl.I.active){
						LANClientCtrl.I.gameEnd();
					}
					break;
				case 'CONTINUE':
					hide();
					break;
			}
		}

	}
}
