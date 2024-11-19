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

package net.play5d.game.bvn {
import flash.display.Sprite;
import flash.display.Stage;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrl.AssetManager;
import net.play5d.game.bvn.ctrl.GameRender;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.EffectModel;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.CongratulateStage;
import net.play5d.game.bvn.stage.CreditsStage;
import net.play5d.game.bvn.stage.GameLoadingStage;
import net.play5d.game.bvn.stage.GameOverStage;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.stage.HowToPlayStage;
import net.play5d.game.bvn.stage.LanguageStage;
import net.play5d.game.bvn.stage.LoadingMosouStage;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.LogoStage;
import net.play5d.game.bvn.stage.MenuStage;
import net.play5d.game.bvn.stage.SelectFighterStage;
import net.play5d.game.bvn.stage.SettingStage;
import net.play5d.game.bvn.stage.WinnerStage;
import net.play5d.game.bvn.stage.WorldMapStage;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.game.bvn.utils.TouchUtils;
import net.play5d.kyo.stage.KyoStageCtrl;
import net.play5d.kyo.utils.KyoTimeout;

public class MainGame {
    include '_INCLUDE_.as';

//		public static const PUBLISH_VERSION_TYPE:int = PublishVersion.COM_4399;
    public static const VERSION:String     = 'V3.7';
    public static var VERSION_LABEL:String = 'V3.7'; // 显示在右下角，与更新逻辑无关
    public static var VERSION_DATE:String  = '2021.10.14';

    public static var UPDATE_INFO:String;

    public static var stageCtrl:KyoStageCtrl;

    public static var I:MainGame;

    public function MainGame() {
        I = this;
    }

    private var _rootSprite:Sprite;
    private var _fps:Number     = 60;
    private var _quality:String = null;

    private var _stage:Stage;

    public function get stage():Stage {
        return _stage;
    }

    public function get root():Sprite {
        return _rootSprite;
    }

    public function initlize(root:Sprite, stage:Stage, initBack:Function = null, initFail:Function = null):void {
        ResUtils.I.initalize(resInitBack, initFail);

        KyoTimeout.init(root);

        if (GameConfig.TOUCH_MODE) {
            TouchUtils.I.init(stage);
        }

        function resInitBack():void {
            AssetManager.I.init();

            GameLogger.log('Initializing resources completed!');

            _rootSprite = root;
            _stage      = stage;

            GameLogger.log('Initializing game rendering...');
            GameRender.initlize(stage);

            GameLogger.log('Initializing game inputter...');
            GameInputer.initlize(_stage);

            GameLogger.log('Initializing game scroll rectangle...');
            root.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);

            GameLogger.log('Initializing scene controller...');
            stageCtrl = new KyoStageCtrl(_rootSprite);

            GameLogger.log('Initializing game configuration...');
            GameData.I.config.applyConfig();

            GameLogger.log('Initializing game inputter configuration...');
            GameInputer.updateConfig();

            GameData.I.loadSaveData();

            if (initBack != null) {
                initBack();
            }
        }
    }

    public function initalizeLoad(initBack:Function = null, initFail:Function = null):void {
        GameLogger.log('Initializing game loading...');

        var loadingState:GameLoadingStage = new GameLoadingStage();
        stageCtrl.goStage(loadingState);
        loadingState.loadGame(loadGameBack, initFail);

        GameEvent.dispatchEvent(GameEvent.LOAD_GAME_START);

        function loadGameBack():void {
            GameLogger.log('Initializing game data...');
            GameData.I.initData();

            GameLogger.log('Initializing game configuration...');
            GameData.I.config.applyConfig();

            GameLogger.log('Initializing game inputter configuration...');
            GameInputer.updateConfig();

            EffectModel.I.initlize();

            GameEvent.dispatchEvent(GameEvent.LOAD_GAME_COMPLETE);

            if (initBack != null) {
                initBack();
            }
        }

    }

    public function getFPS():Number {
        return _fps;
    }

    public function setFPS(v:Number):void {
        _fps             = v;
        _stage.frameRate = v;
        trace('Setting FPS:: ' + v);
    }

    public function setQuality(v:String):void {
        if (_quality == v) {
            return;
        }
        _quality       = v;
        _stage.quality = v;
        trace('Setting Quality:: ' + v);
    }

    /**
     * LOGO界面
     */
    public function goLogo():void {
        stageCtrl.goStage(new LogoStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LogoStage);
    }

    /**
     * 开始界面
     */
    public function goMenu():void {
        resetDefault();
        stageCtrl.goStage(new MenuStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, MenuStage);
    }

    /**
     * HOW TO PLAY
     */
    public function goHowToPlay():void {
        stageCtrl.goStage(new HowToPlayStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, HowToPlayStage);
    }

    /**
     * 选人界面
     */
    public function goSelect():void {
        stageCtrl.goStage(new SelectFighterStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SelectFighterStage);
    }

    /**
     * 加载游戏
     */
    public function loadGame():void {
        if (GameMode.currentMode == GameMode.MOSOU_ACRADE) {
            stageCtrl.goStage(new LoadingMosouStage(), true);
            GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingMosouStage);
        }
        else {
            stageCtrl.goStage(new LoadingStage(), true);
            GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingStage);
        }

        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

    }

    /**
     * 游戏界面
     */
    public function goGame():void {
        var gs:GameStage = new GameStage();
        stageCtrl.goStage(gs);
        GameCtrl.I.startGame();
        setFPS(GameConfig.FPS_GAME);
        setQuality(GameConfig.QUALITY_GAME);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameStage);
    }

    /**
     * 无双模式游戏界面
     */
    public function goMosouGame():void {
        var gs:GameStage = new GameStage();
        stageCtrl.goStage(gs);
        GameCtrl.I.startMosouGame();
        setFPS(GameConfig.FPS_GAME);
        setQuality(GameConfig.QUALITY_GAME);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameStage);
    }

    /**
     * 设置界面
     */
    public function goOption():void {
        stageCtrl.goStage(new SettingStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SettingStage);
    }

    /**
     * CONTINUE界面
     */
    public function goContinue():void {
        var stg:GameOverStage = new GameOverStage();
        stg.showContinue();
        stageCtrl.goStage(stg);
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameOverStage);
    }

    /**
     * GAME OVER界面
     */
    public function goGameOver():void {
        var stg:GameOverStage = new GameOverStage();
        stg.showGameOver();
        stageCtrl.goStage(stg);
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameOverStage);
    }

    /**
     * WINNER界面
     */
    public function goWinner():void {
        var stg:WinnerStage = new WinnerStage();
        stageCtrl.goStage(stg);
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WinnerStage);
    }

    /**
     * 制作组界面
     */
    public function goCredits():void {
        stageCtrl.goStage(new CreditsStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, CreditsStage);
    }

    /**
     * 更多游戏
     */
    public function moreGames():void {
        GameEvent.dispatchEvent(GameEvent.MORE_GAMES);
        GameInterface.instance.moreGames();
    }

    /**
     * 通关
     */
    public function goCongratulations():void {
        stageCtrl.goStage(new CongratulateStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
    }

    /**
     * 提交分数
     */
    public function submitScore():void {
        GameInterface.instance.submitScore(GameData.I.score);
    }

    /**
     * 排行榜
     */
    public function showRank():void {
        GameInterface.instance.showRank();
    }

    /**
     * 大地图
     */
    public function goWorldMap():void {
        stageCtrl.goStage(new WorldMapStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WorldMapStage);
    }

    /**
     * 前往【语言选择】场景
     * @param clickCallBack 点击回调事件
     */
    public function goLanguage(clickCallBack:Function = null):void {
        var languageStage:LanguageStage = new LanguageStage();
        languageStage.clickCallBack     = clickCallBack;
        stageCtrl.goStage(languageStage);

        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
    }

    private function resetDefault():void {
        GameCtrl.I.autoEndRoundAble    = true;
        GameCtrl.I.autoStartAble       = true;
        SelectFighterStage.AUTO_FINISH = true;
        LoadingStage.AUTO_START_GAME   = true;
    }

}
}
