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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.ui.SetBtnGroup;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.stage.IStage;

	public class CongratulateStage implements IStage
	{
		private var _mainUI:Sprite;
		private var _ui:Sprite;
		private var _exitHeight:Number = 0;
		private var _btngroup:SetBtnGroup;
		private var _bg:Bitmap;


		public function CongratulateStage()
		{
		}

		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _mainUI;
		}

		public function get innerUI():Sprite{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{
			_mainUI = new Sprite();

			var bgbd:BitmapData = ResUtils.I.createBitmapData(ResUtils.swfLib.common_ui,'cover_bgimg',GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);
			_bg = new Bitmap(bgbd);
			_mainUI.addChild(_bg);

			_bg.alpha = -1;

			_ui = new Sprite();
			_mainUI.addChild(_ui);

			var ctmc:mc_congratulations = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,ResUtils.CONGRATULATIONS);
			_ui.addChild(ctmc);
			ctmc.addEventListener(Event.COMPLETE,playComplete,false,0,true);
			ctmc.gotoAndPlay(2);

			SoundCtrl.I.BGM(AssetManager.I.getSound('congratulation'));

		}

		public function getBtnY():Number{
			return _btngroup.y;
		}

		private function playComplete(e:Event):void{
			var winallmc:mc_win_all = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,'mc_win_all');
			winallmc.y = GameConfig.GAME_SIZE.y;

			_ui.addChild(winallmc);

			GameRender.add(render);

			var scoretxt:BitmapFontText = new BitmapFontText(AssetManager.I.getFont("font1"));
			scoretxt.text = "FINAL SCORE " + GameData.I.score;
			scoretxt.x = (GameConfig.GAME_SIZE.x - scoretxt.width) / 2;
			scoretxt.y = winallmc.y + winallmc.height + 100;
			_ui.addChild(scoretxt);

			_exitHeight = scoretxt.y - 320;

			_btngroup = new SetBtnGroup();
			//			_btngroup.x = 20;
			_btngroup.x = 230;
			_btngroup.y = scoretxt.y + scoretxt.height + 100;
			_btngroup.setBtnData([{label:"BACK",cn:"返回"}]);
			_btngroup.addEventListener(SetBtnEvent.SELECT,selectBtnHandler);
			_btngroup.keyEnable = false;
			_ui.addChild(_btngroup);

			GameEvent.dispatchEvent(GameEvent.GAME_PASS_ALL);

		}


		private function render():void{

			if(GameInputer.back(1)){
				_ui.y = -_exitHeight;
				SoundCtrl.I.sndSelect();
			}

			_ui.y -= 1;
			_bg.alpha += 0.005;
			if(_ui.y < -_exitHeight){
				GameRender.remove(render);
				_bg.alpha = 1;
//				MainGame.I.goLogo();
				_btngroup.keyEnable = true;
			}
		}

		private function selectBtnHandler(e:SetBtnEvent):void{
			MainGame.I.goLogo();
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
			GameRender.remove(render);

			if(_btngroup){
				_btngroup.destory();
				_btngroup.removeEventListener(SetBtnEvent.SELECT,selectBtnHandler);
				_btngroup = null;
			}

		}
	}
}
