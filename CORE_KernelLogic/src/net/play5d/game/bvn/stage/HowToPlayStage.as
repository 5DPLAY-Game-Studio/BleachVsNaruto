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

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.cntlr.AssetManager;
	import net.play5d.game.bvn.cntlr.GameRender;
	//import net.play5d.game.bvn.ctrl.KeyBoardCtrl;
	import net.play5d.game.bvn.cntlr.KeyEvent;
	import net.play5d.game.bvn.cntlr.SoundCtrl;
	import net.play5d.game.bvn.cntlr.StateCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.KeyConfigVO;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.input.KyoKeyCode;
	import net.play5d.kyo.stage.IStage;

	public class HowToPlayStage implements IStage
	{
		include '../../../../../../include/_INCLUDE_.as';

		private var _ui:movie_howtoplay;

		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.howtoplay , 'movie_howtoplay');
			_ui.addEventListener(Event.COMPLETE,uiComplete);
			_ui.gotoAndPlay(2);

			_ui.mouseChildren = false;

			_ui.graphics.beginFill(0,1);
			_ui.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
			_ui.graphics.endFill();

			SoundCtrl.I.BGM(AssetManager.I.getSound('back'));


			var kc:KeyConfigVO = GameData.I.config.key_p1;

			setKeyText(_ui.txt_up , kc.up);
			setKeyText(_ui.txt_down , kc.down);
			setKeyText(_ui.txt_left , kc.left);
			setKeyText(_ui.txt_right , kc.right);

			setKeyText(_ui.txt_attack , kc.attack);
			setKeyText(_ui.txt_jump , kc.jump);
			setKeyText(_ui.txt_dash , kc.dash);
			setKeyText(_ui.txt_skill , kc.skill);
			setKeyText(_ui.txt_bisha , kc.superKill);
			setKeyText(_ui.txt_special , kc.beckons);

			setTimeout(function():void{
				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;

				_ui.buttonMode = true;
				_ui.addEventListener(MouseEvent.CLICK, skipBtnHandler);
			},100);
//				_ui.skip_btn.addEventListener(MouseEvent.CLICK, skipBtnHandler);
//			},1000);

		}

		private function render():void{
			if(GameInputer.back(1) || GameInputer.select(GameInputType.MENU,1)){
				GameRender.remove(render);
				_ui.gotoAndPlay("skip");
			}
		}

		private function skipBtnHandler(e:MouseEvent):void{
			if(_ui) _ui.removeEventListener(MouseEvent.CLICK, skipBtnHandler);
			if(_ui.skip_btn) _ui.skip_btn.removeEventListener(MouseEvent.CLICK, skipBtnHandler);

			GameRender.remove(render);
			_ui.gotoAndPlay("skip");
		}

		private function uiComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,uiComplete);
			MainGame.I.goSelect();
		}

		private function setKeyText(text:TextField , code:int):void{
			var name:String = KyoKeyCode.code2name(code);
			if(name) text.text = name;
		}

		/**
		 * 稍后构建
		 */
		public function afterBuild():void
		{
		}

		/**
		 * 销毁
		 * @param back 回调函数
		 */
		public function destroy(back:Function =null):void
		{
			SoundCtrl.I.BGM(null);
			GameRender.remove(render);
			_ui.removeEventListener(Event.COMPLETE,uiComplete);
			_ui.gotoAndStop('destory');
		}
	}
}
