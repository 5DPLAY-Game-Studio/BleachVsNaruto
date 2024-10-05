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

package
{
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.play5d.game.bvn.GameQuailty;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.GameLoger;
	import net.play5d.game.bvn.utils.GameSafeKeeper;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.game.bvn.utils.URL;
	import net.play5d.game.bvn.win.GameInterfaceManager;
	import net.play5d.game.bvn.win.MosouDebugger;
	import net.play5d.game.bvn.win.utils.Loger;
	import net.play5d.game.bvn.win.utils.UIAssetUtil;

	[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
	public class launch extends Sprite
	{
		private var _mainGame:MainGame;

		private var _assetLoader:AssetLoader = new AssetLoader();

		public function launch()
		{
			if(stage){
				initlize();
			}else{
				addEventListener(Event.ADDED_TO_STAGE,initlize);
			}
		}

		private function initlize(e:Event = null):void{

			GameLoger.setLoger(new Loger());

			GameLoger.log("init...");

			removeEventListener(Event.ADDED_TO_STAGE,initlize);

			ResUtils.swfLib = new SwfLib();
			AssetManager.I.setAssetLoader(_assetLoader);

			GameInterface.instance = new GameInterfaceManager();

//			if(GameInterfaceManager.config.isFullScreen){
//				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//			}

			GameUI.BITMAP_UI = true;

			GameData.I.config.AI_level = 1;
			GameData.I.config.quality = GameQuailty.MEDIUM;
			GameData.I.config.keyInputMode = 1;

			URL.MARK = 'bvn_win'+MainGame.VERSION;

//			GameSafeKeeper.I.loadConfigure(buildGame, safeFail);
			buildGame();

			MosouDebugger.init(stage);
		}

		private function safeFail(...param):void{
			trace('safe fail !');
		}

		private function buildGame():void{

			GameLoger.log("buildGame");

			_mainGame = new MainGame();
			_mainGame.initlize(this , stage , initBackHandler , initFailHandler);
			if(Debugger.DEBUG_ENABLED) Debugger.initDebug(stage);

			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);

		}

		private function initBackHandler():void{

			GameLoger.log("init ok");

			UIAssetUtil.I.initalize(_mainGame.goLogo);
			//			_mainGame.goMenu();
			//			_mainGame.goCongratulations();
		}

		private function initFailHandler(msg:String):void{
			GameLoger.log("init fail");
		}

		private function keyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.ESCAPE){
				e.preventDefault();
			}
			if(e.keyCode == Keyboard.F11){
				if(stage.displayState == StageDisplayState.NORMAL){
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}else{
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}

	}
}
