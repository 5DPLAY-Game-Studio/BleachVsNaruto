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
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.ScreenRotater;
import net.play5d.game.bvn.mob.ctrls.GamePolyCtrl;
import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
import net.play5d.game.bvn.mob.ctrls.UpdateCtrl;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;
import net.play5d.game.bvn.ui.fight.FightQiBarMode;
import net.play5d.game.bvn.ui.fight.FightUI;
import net.play5d.game.bvn.utils.AssetLoader;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.game.bvn.utils.SwfLib;
import net.play5d.game.bvn.utils.URL;
import net.play5d.kyo.utils.KyoTimerUtils;

[SWF(frameRate='30', backgroundColor='#000000')]
public class launch extends Sprite {
    public function launch() {
        if (stage) {
            initialize();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }
    }
    [Embed(source='/../assets/startup.png')]
    private var startupBitmap:Class;
    private var _startBitmap:Bitmap;
    private var _isActive:Boolean = true;
    private var _assetLoader:AssetLoader = new AssetLoader();

    private function showStartPic():void {
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
        removeStartBitmap();

        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.addEventListener(Event.RESIZE, RootSprite.I.updateFullScreenSize);

        ResUtils.swfLib = new SwfLib();
        AssetManager.I.setAssetLoader(_assetLoader);
        GameInterface.instance = new GameInterfaceManager();

        GameData.I.config.AI_level     = 1;
        GameData.I.config.quality      = GameQuality.MEDIUM;
        GameData.I.config.keyInputMode = 1;

        GameConfig.SHOW_HOW_TO_PLAY = false;

        URL.MARK = 'bvn_mob' + MainGame.VERSION;

        ScreenPadManager.initialize(stage);

        initUI();
    }

    private function initUI():void {
        trace('initUI');
        UIAssetUtil.I.initialize(initGameConfig);
    }

    private function initGameConfig():void {
        var urls:Array = [];
        GamePolyCtrl.I.loadConfig(urls, buildGame);
    }

    private function buildGame():void {
        RootSprite.I.buildGame(initBackHandler, initFailHandler);
    }

    private function initBackHandler():void {
        ScreenPadManager.listen();
        FightUI.QI_BAR_MODE = FightQiBarMode.TOP;

        UpdateCtrl.I.update(null, updateBack);
    }

    private function updateBack():void {
        RootSprite.I.getMainGame().goMenu();
    }

    private function initFailHandler(msg:String):void {
        NativeApplication.nativeApplication.exit();
    }

    private function initialize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initialize);
        STAGE = stage;

        stage.align     = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        GameConfig.TOUCH_MODE = true; //开启触屏模式

        ScreenRotater.I.init(stage);

        showStartPic();
        initGame();
    }

    private function activeHandler(e:Event):void {
        if (e.type == Event.DEACTIVATE) {
            if (!_isActive) {
                return;
            }

            _isActive = false;
            trace('pause');
            KyoTimerUtils.pauseAllTimer();
            MobileCtrler.I.pause();
        }
        else {
            if (_isActive) {
                return;
            }

            _isActive = true;
            trace('resume');
            KyoTimerUtils.resumeAllTimer();
            MobileCtrler.I.resume();
        }
    }

    private function keyHandler(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.BACK) {
            e.preventDefault();
        }
    }

}
}
