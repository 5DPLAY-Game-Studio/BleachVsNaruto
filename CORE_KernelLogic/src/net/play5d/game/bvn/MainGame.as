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

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.ConfigCtrl;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.EffectModel;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.LanguageType;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.CongratulateStage;
import net.play5d.game.bvn.stage.CreditsStage;
import net.play5d.game.bvn.stage.GameLoadingStage;
import net.play5d.game.bvn.stage.GameOverStage;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.stage.HowToPlayStage;
import net.play5d.game.bvn.stage.LanguageStage;
import net.play5d.game.bvn.stage.LoadingMusouStage;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.LogoStage;
import net.play5d.game.bvn.stage.MenuStage;
import net.play5d.game.bvn.stage.SelectFighterStage;
import net.play5d.game.bvn.stage.SettingStage;
import net.play5d.game.bvn.stage.WinnerStage;
import net.play5d.game.bvn.stage.WorldMapStage;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.MultiLangUtils;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.game.bvn.utils.TouchUtils;
import net.play5d.kyo.stage.KyoStageCtrl;
import net.play5d.kyo.utils.KyoTimeout;

/**
 * 场景入口。构造时把自己写成 <code>I</code>，再构造一次会换掉。
 *
 * <p><code>stageCtrl</code> 要等 <code>initialize</code> 的资源回调走完才有，在那之前切场景会抛错。切场景默认拒绝换成同类，但帧率、画质和 <code>ENTER_STAGE</code> 仍会执行。<code>loadGame</code> 允许换成同类。<code>goCongratulations</code> 和 <code>goLanguage</code> 不派 <code>ENTER_STAGE</code>。</p>
 */
public class MainGame {

    /**
     * 版本号，取自 <code>GameVersion.VERSION</code>。
     */
    public static const VERSION:String     = GameVersion.VERSION;
    /**
     * 右下角显示的版本文字，不参与更新判断。初始和 <code>VERSION</code> 相同，之后可以单独改。
     */
    public static var VERSION_LABEL:String = GameVersion.VERSION;
    /**
     * 版本日期。
     *
     * @default 2021.10.14
     */
    public static var VERSION_DATE:String  = '2021.10.14';

    /**
     * 更新说明。
     *
     * @default null
     */
    public static var UPDATE_INFO:String;

    /**
     * 场景控制器。资源回调完成前是 null。
     *
     * @default null
     */
    public static var stageCtrl:KyoStageCtrl;

    /**
     * 最近一次构造的实例。
     *
     * @default null
     */
    public static var I:MainGame;

    /**
     * 把 <code>I</code> 写成自己。
     */
    public function MainGame() {
        I = this;
    }

    private var _rootSprite:Sprite;
    private var _fps:Number     = 60;
    private var _quality:String = null;

    private var _stage:Stage;

    /**
     * 舞台。资源回调完成前是 null。
     *
     * @return 舞台。
     */
    public function get stage():Stage {
        return _stage;
    }

    /**
     * 根显示对象。资源回调完成前是 null。
     *
     * @return 根显示对象。
     */
    public function get root():Sprite {
        return _rootSprite;
    }

    /**
     * 初始化资源和输入。先打开 SWF 库，根显示对象交给超时器。触屏模式会初始化触摸。
     *
     * <p>库加载成功后读存档语言，空字符串也改用简体，再初始化多语言。多语言完成后才记下根和舞台、启动渲染和输入、把滚动区域设成游戏尺寸、创建 <code>stageCtrl</code> 并套用配置，然后调用成功回调。失败回调交给资源和多语言。再次走到完成回调会再套一遍配置，并新建一个 <code>stageCtrl</code>。</p>
     *
     * @param root 根显示对象。
     * @param stage 舞台。触屏模式下为 null 时，第一次按下才抛错。
     * @param initBack 全部就绪后调用。默认 null。
     * @param initFail 资源或多语言失败时调用。默认 null。
     * @throws Error 库正在初始化，或库还没赋值时。
     * @example
     * <listing version="3.0">
     * game.initialize(root, stage, onReady, onFail);
     * </listing>
     */
    public function initialize(root:Sprite, stage:Stage, initBack:Function = null, initFail:Function = null):void {
        ResUtils.I.initialize(resInitBack, initFail);

        KyoTimeout.init(root);

        if (GameConfig.TOUCH_MODE) {
            TouchUtils.I.init(stage);
        }

        function resInitBack():void {
            AssetManager.I.init();
            GameData.I.loadSaveData();

            // 存档语言先于启动日志。语言界面点选后会再加载一次。
            var language:String = GameData.I.config.language || LanguageType.CHINESE_SIMPLIFIED;
            LANGUAGE            = language;
            MultiLangUtils.I.initialize(language, boot, initFail);
        }

        function boot():void {
            LogLang(GameLogger.INFO, 'sys', 'main_game.resources_ready');

            _rootSprite = root;
            _stage      = stage;

            LogLang(GameLogger.INFO, 'sys', 'main_game.render');
            GameRender.initialize(stage);

            LogLang(GameLogger.INFO, 'sys', 'main_game.input');
            GameInputter.initialize(_stage);

            LogLang(GameLogger.INFO, 'sys', 'main_game.scroll_rect');
            root.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);

            LogLang(GameLogger.INFO, 'sys', 'main_game.stage_ctrl');
            stageCtrl = new KyoStageCtrl(_rootSprite);

            LogLang(GameLogger.INFO, 'sys', 'main_game.config');
            ConfigCtrl.apply(GameData.I.config);

            LogLang(GameLogger.INFO, 'sys', 'main_game.input_config');
            GameInputter.updateConfig();

            if (initBack != null) {
                initBack();
            }
        }
    }

    /**
     * 进入加载场景并加载游戏数据。调用时就派 <code>LOAD_GAME_START</code>，完成回调里才派 <code>LOAD_GAME_COMPLETE</code>。
     *
     * <p><code>stageCtrl</code> 还没有时抛错。完成后会初始化数据、再套配置、初始化效果，然后调用成功回调。</p>
     *
     * @param initBack 加载并初始化完成后调用。默认 null。
     * @param initFail 交给加载场景。默认 null。
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.initializeLoad(onLoaded, onFail);
     * </listing>
     */
    public function initializeLoad(initBack:Function = null, initFail:Function = null):void {
        LogLang(GameLogger.INFO, 'sys', 'main_game.loading');

        var loadingState:GameLoadingStage = new GameLoadingStage();
        stageCtrl.goStage(loadingState);
        loadingState.loadGame(loadGameBack, initFail);

        GameEvent.dispatchEvent(GameEvent.LOAD_GAME_START);

        function loadGameBack():void {
            LogLang(GameLogger.INFO, 'sys', 'main_game.data');
            GameData.I.initData();

            LogLang(GameLogger.INFO, 'sys', 'main_game.config');
            ConfigCtrl.apply(GameData.I.config);

            LogLang(GameLogger.INFO, 'sys', 'main_game.input_config');
            GameInputter.updateConfig();

            EffectModel.I.initialize();

            GameEvent.dispatchEvent(GameEvent.LOAD_GAME_COMPLETE);

            if (initBack != null) {
                initBack();
            }
        }

    }

    /**
     * 自己记下的帧率。默认 60，不是舞台上的当前值。
     *
     * @return 帧率。
     * @example
     * <listing version="3.0">
     * var fps:Number = game.getFPS();
     * </listing>
     */
    public function getFPS():Number {
        return _fps;
    }

    /**
     * 同时改自己记下的帧率和舞台帧率。舞台还没有时抛错。
     *
     * @param v 帧率。
     * @throws TypeError 舞台还没有时。
     * @example
     * <listing version="3.0">
     * game.setFPS(30);
     * </listing>
     */
    public function setFPS(v:Number):void {
        _fps             = v;
        _stage.frameRate = v;
        GameLogger.debug('sys', 'Setting FPS: ' + v);
    }

    /**
     * 改舞台画质。和上次相同则直接返回。初始值是 null，第一次一定会写。舞台还没有时抛错。
     *
     * @param v 画质。
     * @throws TypeError 舞台还没有时。
     * @example
     * <listing version="3.0">
     * game.setQuality(GameConfig.QUALITY_UI);
     * </listing>
     */
    public function setQuality(v:String):void {
        if (_quality == v) {
            return;
        }
        _quality       = v;
        _stage.quality = v;
        GameLogger.debug('sys', 'Setting Quality: ' + v);
    }

    /**
     * 进入标志场景，帧率和画质改成界面用的。场景控制器还没有时抛错。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goLogo();
     * </listing>
     */
    public function goLogo():void {
        stageCtrl.goStage(new LogoStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LogoStage);
    }

    /**
     * 进入标题。先把自动结束回合、自动开战、选人自动完成、加载后自动开战都写成 true。
     *
     * @throws TypeError 场景控制器或对局控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goMenu();
     * </listing>
     */
    public function goMenu():void {
        resetDefault();
        stageCtrl.goStage(new MenuStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, MenuStage);
    }

    /**
     * 进入操作说明，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goHowToPlay();
     * </listing>
     */
    public function goHowToPlay():void {
        stageCtrl.goStage(new HowToPlayStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, HowToPlayStage);
    }

    /**
     * 进入选人，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goSelect();
     * </listing>
     */
    public function goSelect():void {
        stageCtrl.goStage(new SelectFighterStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SelectFighterStage);
    }

    /**
     * 进入加载场景，并允许换成同类场景。无双街机用无双加载，其它模式用普通加载。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.loadGame();
     * </listing>
     */
    public function loadGame():void {
        if (GameMode.currentMode == GameMode.MUSOU_ARCADE) {
            stageCtrl.goStage(new LoadingMusouStage(), true);
            GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingMusouStage);
        }
        else {
            stageCtrl.goStage(new LoadingStage(), true);
            GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, LoadingStage);
        }

        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

    }

    /**
     * 进入对局并调用 <code>startGame</code>。启动抛错时，帧率、画质和进入事件都不会改。
     *
     * @throws TypeError 对局控制器或场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goGame();
     * </listing>
     */
    public function goGame():void {
        enterGameStage(GameCtrl.I.startGame);
    }

    /**
     * 进入对局并调用 <code>startMusouGame</code>。启动抛错时，帧率、画质和进入事件都不会改。
     *
     * @throws TypeError 对局控制器或场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goMusouGame();
     * </listing>
     */
    public function goMusouGame():void {
        enterGameStage(GameCtrl.I.startMusouGame);
    }

    /**
     * 组装并切入对局场景，按给定回调启动对战/无双会话。
     * @param start 启动回调。
     */
    private function enterGameStage(start:Function):void {
        var gs:GameStage = new GameStage(GameCtrl.I, EffectCtrl.I);
        stageCtrl.goStage(gs);
        start();
        setFPS(GameConfig.FPS_GAME);
        setQuality(GameConfig.QUALITY_GAME);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, GameStage);
    }

    /**
     * 进入设置，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goOption();
     * </listing>
     */
    public function goOption():void {
        stageCtrl.goStage(new SettingStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, SettingStage);
    }

    /**
     * 进入继续画面。和结束画面是同一个场景类，这里播继续。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goContinue();
     * </listing>
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
     * 进入结束画面。和继续画面是同一个场景类，这里播结束。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goGameOver();
     * </listing>
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
     * 进入胜利场景，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goWinner();
     * </listing>
     */
    public function goWinner():void {
        var stg:WinnerStage = new WinnerStage();
        stageCtrl.goStage(stg);
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WinnerStage);
    }

    /**
     * 进入制作组场景，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goCredits();
     * </listing>
     */
    public function goCredits():void {
        stageCtrl.goStage(new CreditsStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, CreditsStage);
    }

    /**
     * 派更多游戏事件，再交给外壳。没有外壳实例时抛错。
     *
     * @throws TypeError 外壳实例为 null 时。
     * @example
     * <listing version="3.0">
     * game.moreGames();
     * </listing>
     */
    public function moreGames():void {
        GameEvent.dispatchEvent(GameEvent.MORE_GAMES);
        GameInterface.instance.moreGames();
    }

    /**
     * 进入通关场景。不派进入场景事件。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goCongratulations();
     * </listing>
     */
    public function goCongratulations():void {
        stageCtrl.goStage(new CongratulateStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);
    }

    /**
     * 把当前分数交给外壳。没有外壳实例时抛错。
     *
     * @throws TypeError 外壳实例为 null 时。
     * @example
     * <listing version="3.0">
     * game.submitScore();
     * </listing>
     */
    public function submitScore():void {
        GameInterface.instance.submitScore(GameData.I.score);
    }

    /**
     * 打开外壳排行榜。没有外壳实例时抛错。
     *
     * @throws TypeError 外壳实例为 null 时。
     * @example
     * <listing version="3.0">
     * game.showRank();
     * </listing>
     */
    public function showRank():void {
        GameInterface.instance.showRank();
    }

    /**
     * 进入大地图，帧率和画质改成界面用的。
     *
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goWorldMap();
     * </listing>
     */
    public function goWorldMap():void {
        stageCtrl.goStage(new WorldMapStage());
        setFPS(GameConfig.FPS_UI);
        setQuality(GameConfig.QUALITY_UI);

        GameEvent.dispatchEvent(GameEvent.ENTER_STAGE, WorldMapStage);
    }

    /**
     * 进入语言选择。回调直接赋给场景，不派进入场景事件。
     *
     * @param clickCallBack 点选语言后的回调。默认 null。
     * @throws TypeError 场景控制器还没有时。
     * @example
     * <listing version="3.0">
     * game.goLanguage(onLang);
     * </listing>
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
