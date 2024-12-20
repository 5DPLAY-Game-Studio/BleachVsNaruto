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

package {
import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.ScreenRotater;
import net.play5d.game.bvn.mob.SwfLib;
import net.play5d.game.bvn.mob.ads.AdManager;
import net.play5d.game.bvn.mob.ads.ctrl.AdCtrler;
import net.play5d.game.bvn.mob.ctrls.GamePolyCtrl;
import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
import net.play5d.game.bvn.mob.ctrls.UpdateCtrl;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.TimerOutUtils;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.fight.FightQiBarMode;
import net.play5d.game.bvn.ui.fight.FightUI;
import net.play5d.game.bvn.utils.AssetLoader;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.game.bvn.utils.URL;

//	import net.play5d.game.bvn.mob.utils.UMengAneManager;
[SWF(frameRate='30', backgroundColor='#000000')]
public class launch extends Sprite {
//		private var _mainGame:MainGame;
//		private var _gameSprite:Sprite;
    public function launch() {
//			I = this;
//			addEventListener(Event.ADDED_TO_STAGE,initlize);

        if (stage) {
            initlize();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, initlize);
        }
    }
//		private var _gameSideBg:GameSideBg;
    [Embed(source='/../assets/startup.png')]
    private var startupBitmap:Class;
    private var _startBitmap:Bitmap;
    private var _sdkTimer:int;
//		private var _initTimer:int;
    private var _isActive:Boolean = true;

//		private var _showGameSide:Boolean = false;
//
//		public static var FULL_SCREEN_SIZE:Point = new Point();
//
//		public static var STAGE:Stage;
//
//		public static var I:launch;
    private var _preInited:Boolean = false;
    private var _assetLoader:AssetLoader = new AssetLoader();

//		public function addChildToGameSprite(v:DisplayObject):void{
//			_gameSprite && _gameSprite.addChild(v);
//		}

    private function showStartPic():void {
//			AdManager.toast("showStartPic");

        RootSprite.STAGE = stage;
        RootSprite.I.init(this);
        RootSprite.I.updateFullScreenSize();

        stage.addEventListener(Event.DEACTIVATE, activeHandler);
        stage.addEventListener(Event.ACTIVATE, activeHandler);

        _startBitmap        = new startupBitmap();
        _startBitmap.width  = RootSprite.FULL_SCREEN_SIZE.x;
        _startBitmap.height = RootSprite.FULL_SCREEN_SIZE.y;

        addChild(_startBitmap);
    }

    private function initSDK():void {
//			AdManager.toast("initSDK");

//			var ads:Vector.<IAd> = new Vector.<IAd>();
//			var csj:CSJAd = new CSJAd("5213224","887554940","946640343","946860998");
//			csj.setADEnabled("OPEN",true);
//			csj.setADEnabled("INTER",false);
//			csj.setADEnabled("VIDEO",true);
//			csj.setADEnabled("REWARD_VIDEO",true);
//			csj.setADEnabled("NATIVE",true);
//			csj.setRankAndRate("OPEN",10,100);
//			csj.setRankAndRate("VIDEO",6,80);
//			csj.setRankAndRate("REWARD_VIDEO",5,100);
//			csj.setRankAndRate("NATIVE",10,100);
//			ads.push(csj);
//
//			var gdt:GDTAd = new GDTAd("1110076897","3082021928935304","3072533491204880","7032629938039577",null);
//			gdt.setADEnabled("OPEN",false);
//			gdt.setADEnabled("INTER",true);
//			gdt.setADEnabled("VIDEO",true);
//			gdt.setADEnabled("REWARD_VIDEO",true);
//			gdt.setADEnabled("NATIVE",false);
//			gdt.setRankAndRate("INTER",10,100);
//			gdt.setRankAndRate("VIDEO",5,100);
//			gdt.setRankAndRate("REWARD_VIDEO",6,20);
//			gdt.setRankAndRate("NATIVE",6,30);
//			ads.push(gdt);
//
//			AdManager.I.initAD(ads, false, sdkBack, adBack);

        sdkBack();
        adBack();
        _sdkTimer = TimerOutUtils.setTimeout(initGame, 10000);

        //竞技版删除广告

    }

    private function sdkBack():void {
        trace('sdkBack');
        TimerOutUtils.clearTimeout(_sdkTimer);
    }

    private function adBack():void {
//			AdManager.toast("adBack");

        TimerOutUtils.clearTimeout(_sdkTimer);
        preInitGame();

        if (AdCtrler.SHOW_OPENAD_ON_START) {
            TimerOutUtils.setTimeout(initGame, 500);
        }
        else {
            initGame();
        }
    }

    private function preInitGame():void {
        if (_preInited) {
            return;
        }
        _preInited = true;
//
//			if(_startBitmap){
//				try{
//					removeChild(_startBitmap);
//				}catch(e:Error){}
//				_startBitmap.bitmapData.dispose();
//				_startBitmap = null;
//			}
//
//			ScreenRotater.I.init(stage);

    }

    private function removeStartBitmap():void {
        if (_startBitmap) {
            try {
                removeChild(_startBitmap);
            }
            catch (e:Error) {
            }

            _startBitmap.bitmapData.dispose();
            _startBitmap = null;
        }
    }

    private function initGame():void {
        TimerOutUtils.clearTimeout(_sdkTimer);
//			TimerOutUtils.clearTimeout(_initTimer);

        preInitGame();
        removeStartBitmap();

        if (!AdManager.I.checkPackage()) {
            trace('check package name failure!');
            NativeApplication.nativeApplication.exit();
            return;
        }

        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.addEventListener(Event.RESIZE, RootSprite.I.updateFullScreenSize);


        ResUtils.swfLib = new SwfLib();
        AssetManager.I.setAssetLoader(_assetLoader);
        GameInterface.instance = new GameInterfaceManager();

        GameData.I.config.AI_level     = 1;
        GameData.I.config.quality      = GameQuality.MEDIUM;
        GameData.I.config.keyInputMode = 1;

        GameConfig.SHOW_HOW_TO_PLAY = false;

//			UIUtils.LOCK_FONT = "Droid Sans Fallback";

        URL.MARK = 'bvn_mob' + MainGame.VERSION;

        ScreenPadManager.initlize(stage);

        //			englishVersion();

        //			ScreenPadManager.testMode();
        //			return;

//			return; //逐行排查错误！
//			GameSafeKeeper.I.loadConfigure(initUI, safeFail);

        initUI();
    }

    private function initUI():void {
        trace('initUI');
        UIAssetUtil.I.initalize(initGameConfig);
    }

    private function englishVersion():void {
        GameUI.SHOW_CN_TEXT                  = false;
        GameInterfaceManager.ENGLISH_VERSION = true;
    }

    private function initGameConfig():void {
        var urls:Array = [
            'http://1212321.cn-sh2.ufileos.com/upload/BVN_37.ini', 'http://1212321.com/file/get/BVN_37.ini'
        ];
        GamePolyCtrl.I.loadConfig(urls, gamePolyComplete);
    }

    private function gamePolyComplete():void {
        AdManager.I.updatePolity();
        AdManager.I.beforeGameInit();
        buildGame();
    }

    private function buildGame():void {
//			updateFullScreenSize();

//			_gameSprite = new Sprite();
        //			_gameSprite.scaleX = stage.fullScreenWidth / GameConfig.GAME_SIZE.x;
        //			_gameSprite.scaleY = stage.fullScreenHeight / GameConfig.GAME_SIZE.y;
//			addChild(_gameSprite);

//			_mainGame = new MainGame();
//			_mainGame.initlize(_gameSprite , stage , initBackHandler , initFailHandler);

//			if(Debugger.DEBUG_ENABLED) Debugger.initDebug(stage);

        RootSprite.I.buildGame(initBackHandler, initFailHandler);

        GameEvent.addEventListener(GameEvent.ENTER_SINGLE_STAGE, enterStageHandler);
        GameEvent.addEventListener(GameEvent.ENTER_TEAM_STAGE, enterStageHandler);
        GameEvent.addEventListener(GameEvent.ENTER_TRAIN_STAGE, enterStageHandler);
        GameEvent.addEventListener(GameEvent.ENTER_MOSOU_STAGE, enterStageHandler);
    }

    private function initBackHandler():void {
        ScreenPadManager.listen();
        FightUI.QI_BAR_MODE = FightQiBarMode.TOP;

        UpdateCtrl.I.update(null, updateBack);
    }

    private function updateBack():void {
        AdManager.I.onGameInited();
        RootSprite.I.getMainGame().goMenu();
    }

    private function initFailHandler(msg:String):void {
        NativeApplication.nativeApplication.exit();
    }

    private function initlize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initlize);

        stage.align     = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.mouseChildren = false;

        AdCtrler.SHOW_OPENAD_ON_START = true;

			GameConfig.TOUCH_MODE = true;//开启触屏模式

        ScreenRotater.I.init(stage);

        showStartPic();
        initSDK();

//			stage.autoOrients = false;
//
//			updateFullScreenSize();
//
//			stage.addEventListener(Event.DEACTIVATE,activeHandler);
//			stage.addEventListener(Event.ACTIVATE,activeHandler);
//
//
//			_startBitmap = new startupBitmap();
//			_startBitmap.width = FULL_SCREEN_SIZE.x;
//			_startBitmap.height = FULL_SCREEN_SIZE.y;
//			_startBitmap.rotation = 90;
//			_startBitmap.x = FULL_SCREEN_SIZE.y;
//			addChild(_startBitmap);
//
//			STAGE = stage;
//
//			AdManager.I.initAD(sdkBack, adBack);
//
//			_sdkTimer = TimerOutUtils.setTimeout(initGame , 10000);
    }

    private function activeHandler(e:Event):void {
        if (e.type == Event.DEACTIVATE) {
            if (!_isActive) {
                return;
            }

            _isActive = false;
            trace('pause');
            TimerOutUtils.pauseAllTimer();
            MobileCtrler.I.pause();
//				UMengAneManager.I.onDeactive();
            AdManager.I.onDeactive();
        }
        else {
            if (_isActive) {
                return;
            }

            _isActive = true;
            trace('resume');
            TimerOutUtils.resumeAllTimer();
            MobileCtrler.I.resume();
//				UMengAneManager.I.onActive();
            AdManager.I.onActive();
        }
    }

    private function keyHandler(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.BACK) {
            //				GameCtrl.I.pause(true);
            //				GameUI.confrim('EXIT GAME','退出游戏？',NativeApplication.nativeApplication.exit);
            e.preventDefault();
        }
    }

    private function enterStageHandler(e:GameEvent):void {
        switch (e.type) {
        case GameEvent.ENTER_SINGLE_STAGE:
//					UMengAneManager.I.sendEvent("game_mode_single");
            break;
        case GameEvent.ENTER_TEAM_STAGE:
//					UMengAneManager.I.sendEvent("game_mode_team");
            break;
        case GameEvent.ENTER_TRAIN_STAGE:
//					UMengAneManager.I.sendEvent("game_mode_train");
            break;
        case GameEvent.ENTER_MOSOU_STAGE:
//					UMengAneManager.I.sendEvent("game_mode_mosou");
        }
    }

}
}
