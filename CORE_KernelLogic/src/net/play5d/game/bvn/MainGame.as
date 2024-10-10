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

package net.play5d.game.bvn
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.DataEvent;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.EffectModel;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.data.SelectVO;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.stage.CongratulateState;
	import net.play5d.game.bvn.stage.CreditsState;
	import net.play5d.game.bvn.stage.GameLoadingState;
	import net.play5d.game.bvn.stage.GameOverState;
	import net.play5d.game.bvn.stage.GameState;
	import net.play5d.game.bvn.stage.HowToPlayState;
import net.play5d.game.bvn.stage.LanguageStage;
import net.play5d.game.bvn.stage.LoadingMosouState;
import net.play5d.game.bvn.stage.LoadingState;
	import net.play5d.game.bvn.stage.LogoState;
	import net.play5d.game.bvn.stage.MenuState;
	import net.play5d.game.bvn.stage.SelectFighterStage;
	import net.play5d.game.bvn.stage.SettingState;
	import net.play5d.game.bvn.stage.WinnerState;
	import net.play5d.game.bvn.stage.WorldMapState;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.GameLoger;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.game.bvn.utils.TouchUtils;
	import net.play5d.kyo.stage.KyoStageCtrl;
	import net.play5d.kyo.utils.KyoTimeout;

	public class MainGame
	{

//		public static const PUBLISH_VERSION_TYPE:int = PublishVersion.COM_4399;
		public static const VERSION:String = "V3.7";
		public static var VERSION_LABEL:String = "V3.7"; // 显示在右下角，与更新逻辑无关
		public static var VERSION_DATE:String = "2021.10.14";

		public static var UPDATE_INFO:String;

		public static var stageCtrl:KyoStageCtrl;

		public static var I:MainGame;

		private var _rootSprite:Sprite;
		private var _stage:Stage;

		public function get root():Sprite{
			return _rootSprite;
		}

		public function get stage():Stage{
			return _stage;
		}

		public function MainGame()
		{
			I = this;
		}

		public function initlize(root:Sprite , stage:Stage , initBack:Function = null , initFail:Function = null):void {
			ResUtils.I.initalize(resInitBack , initFail);

			KyoTimeout.init(root);

			if(GameConfig.TOUCH_MODE){
				TouchUtils.I.init(stage);
			}

			function resInitBack():void{
				AssetManager.I.init();

				GameLoger.log("res init ok");

				_rootSprite = root;
				_stage = stage;

				GameLoger.log("init game render");
				GameRender.initlize(stage);

				GameLoger.log("init game inputer");
				GameInputer.initlize(_stage);

				GameLoger.log("init scroll");
				root.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);

				GameLoger.log("init stagectrl");
				stageCtrl = new KyoStageCtrl(_rootSprite);

				GameLoger.log("init config");
				GameData.I.config.applyConfig();

				GameLoger.log("init inputer config");
				GameInputer.updateConfig();

				GameData.I.loadSaveData();

				if(initBack != null){
					initBack();
				}
			}
		}

		public function initalizeLoad(initBack:Function = null , initFail:Function = null):void{
			GameLoger.log("init loading");

			var loadingState:GameLoadingState = new GameLoadingState();
			stageCtrl.goStage(loadingState);
			loadingState.loadGame(loadGameBack , initFail);

			GameEvent.dispatchEvent(GameEvent.LOAD_GAME_START);

			function loadGameBack():void{
				GameLoger.log("init game data");
				GameData.I.initData();

				GameLoger.log("init config");
				GameData.I.config.applyConfig();

				GameLoger.log("init inputer config");
				GameInputer.updateConfig();

				EffectModel.I.initlize();

				GameEvent.dispatchEvent(GameEvent.LOAD_GAME_COMPLETE);

				if(initBack != null){
					initBack();
				}
			}

		}

		private function resetDefault():void{
			GameCtrl.I.autoEndRoundAble = true;
			GameCtrl.I.autoStartAble = true;
			SelectFighterStage.AUTO_FINISH = true;
			LoadingState.AUTO_START_GAME = true;
		}

		private var _fps:Number = 60;
		public function getFPS():Number{
			return _fps;
		}

		private var _quality:String = null;
		public function setFPS(v:Number):void{
			_fps = v;
			_stage.frameRate = v;
			trace('setFPS :: ', v);
		}

		public function setQuality(v:String):void{
			if(_quality == v) return;
			_quality = v;
			_stage.quality = v;
			trace('setQuality :: ', v);
		}

		/**
		 * LOGO界面
		 */
		public function goLogo():void{
			stageCtrl.goStage(new LogoState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);

			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LogoState);
		}

		/**
		 * 开始界面
		 */
		public function goMenu():void{
			resetDefault();
			stageCtrl.goStage(new MenuState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);

			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, MenuState);

//			GameUI.alert('TEST', '测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试');
//			GameUI.confrim('TEST TEST TEST', '测试测试');
		}

		/**
		 * HOW TO PLAY
		 */
		public function goHowToPlay():void{
			stageCtrl.goStage(new HowToPlayState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, HowToPlayState);
		}

		/**
		 * 选人界面
		 */
		public function goSelect():void{
			stageCtrl.goStage(new SelectFighterStage());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SelectFighterStage);
		}

		/**
		 * 加载游戏
		 */
		public function loadGame():void{
			if(GameMode.currentMode == GameMode.MOSOU_ACRADE){
				stageCtrl.goStage(new LoadingMosouState(), true);
				GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingMosouState);
			}else{
				stageCtrl.goStage(new LoadingState(), true);
				GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingState);
			}

			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);

		}

		/**
		 * 游戏界面
		 */
		public function goGame():void{
			var gs:GameState = new GameState();
			stageCtrl.goStage(gs);
			GameCtrl.I.startGame();
			setFPS(GameConfig.FPS_GAME);
			setQuality(GameConfig.QUALITY_GAME);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameState);
		}

		/**
		 * 无双模式游戏界面
		 */
		public function goMosouGame():void{
			var gs:GameState = new GameState();
			stageCtrl.goStage(gs);
			GameCtrl.I.startMosouGame();
			setFPS(GameConfig.FPS_GAME);
			setQuality(GameConfig.QUALITY_GAME);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameState);
		}

		/**
		 * 设置界面
		 */
		public function goOption():void{
			stageCtrl.goStage(new SettingState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SettingState);
		}

		/**
		 * CONTINUE界面
		 */
		public function goContinue():void{
			var stg:GameOverState = new GameOverState();
			stg.showContinue();
			stageCtrl.goStage(stg);
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameOverState);
		}

		/**
		 * GAME OVER界面
		 */
		public function goGameOver():void{
			var stg:GameOverState = new GameOverState();
			stg.showGameOver();
			stageCtrl.goStage(stg);
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameOverState);
		}

		/**
		 * WINNER界面
		 */
		public function goWinner():void{
			var stg:WinnerState = new WinnerState();
			stageCtrl.goStage(stg);
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WinnerState);
		}

		/**
		 * 制作组界面
		 */
		public function goCredits():void{
			stageCtrl.goStage(new CreditsState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, CreditsState);
		}

		/**
		 * 更多游戏
		 */
		public function moreGames():void{
			GameEvent.dispatchEvent(GameEvent.MORE_GAMES);
			GameInterface.instance.moreGames();
		}

		/**
		 * 通关
		 */
		public function goCongratulations():void{
			stageCtrl.goStage(new CongratulateState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
		}


		/**
		 * 提交分数
		 */
		public function submitScore():void{
			GameInterface.instance.submitScore(GameData.I.score);
		}

		/**
		 * 排行榜
		 */
		public function showRank():void{
			GameInterface.instance.showRank();
		}

		/**
		 * 大地图
		 */
		public function goWorldMap():void{
			stageCtrl.goStage(new WorldMapState());
			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);

			GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WorldMapState);
		}

		/**
		 * 前往【语言选择】场景
		 */
		public function goLanguage(clickCallBack:Function = null):void {
			var languageStage:LanguageStage = new LanguageStage();
			languageStage.clickCallBack = clickCallBack;
			stageCtrl.goStage(languageStage);

			setFPS(GameConfig.FPS_UI);
			setQuality(GameConfig.QUALITY_UI);
		}

	}
}
