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
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.PopUpListView;
import feathers.data.ArrayCollection;
import feathers.style.Theme;
import feathers.text.TextFormat;
import feathers.themes.steel.SteelTheme;

import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowRenderMode;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.TrainingCtrler;
import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.debug.DebugMain;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.test.GameInterfaceManager;
import net.play5d.game.bvn.test.SwfLib;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.game.bvn.utils.AssetLoader;
import net.play5d.game.bvn.utils.GithubUtils;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.storage.KyoSharedObject;

//	import flash.text.TextFormat;

[SWF(width='800', height='600', frameRate='30', backgroundColor='#000000')]
public class FighterTester extends Sprite {
    private const KEY:String = 'text';

    /** @private 调试面板内容宽 */
    private static const DEBUG_PANEL_WIDTH:Number = 200;
    /** @private 调试面板内容高 */
    private static const DEBUG_PANEL_HEIGHT:Number = 600;
    /** @private 下拉/输入控件宽 */
    private static const CONTROL_WIDTH:Number = 182;
    /** @private 按钮宽 */
    private static const BUTTON_WIDTH:Number = 175;
    /** @private 内容区底边（末行按钮 y + height） */
    private static const CONTENT_BOTTOM:Number = 590;

    public function FighterTester() {
        // 忽略旧版角色
        GameStageLoadCtrl.IGNORE_OLD_FIGHTER = true;

        if (stage) {
            initialize();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }
    }
    private var _theme:SteelTheme;
    private var _mainGame:MainGame;
    private var _testUI:Sprite;
    private var _testContent:Sprite;
    private var _debugWindow:NativeWindow;
    private var _p1InputId:PopUpListView;
    private var _p2InputId:PopUpListView;
    private var _p1FzInputId:PopUpListView;
    private var _p2FzInputId:PopUpListView;
    private var _autoReceiveHp:PopUpListView;
    private var _mapInputId:PopUpListView;
    private var _fpsInput:PopUpListView;
    private var _debugText:Label;

    private var _gameSprite:Sprite;
    private var _assetLoader:AssetLoader = new AssetLoader();
    /** @private 正在执行吸附，避免 MOVE 回调递归 */
    private var _docking:Boolean;

    private function initBackHandler():void {
        buildTestUI();
    }

    private function initFailHandler(msg:String):void {

    }

    private function buildTestUI():void {
        _testUI      = new Sprite();
        _testContent = new Sprite();
        _testUI.addChild(_testContent);

        var xx:Number = (DEBUG_PANEL_WIDTH - CONTROL_WIDTH) * 0.5;
        var yy:Number = 0;
        var bx:Number = (DEBUG_PANEL_WIDTH - BUTTON_WIDTH) * 0.5;

        var fighterData:Array = (
                function ():Array {
                    var data:Array = [];

                    var fightersObj:Object = FighterModel.I.getAllFighters();
                    for each (var fighter:FighterVO in fightersObj) {
                        data.push({text: fighter.id});
                    }

                    data.sort(function (a:Object, b:Object):int {
                        if (a[KEY] > b[KEY]) {
                            return 1;
                        }
                        else if (a[KEY] < b[KEY]) {
                            return -1;
                        }

                        return 0;
                    });

                    return data;
                }
        )();
        addLabel(GetLang('dev.txt.fighter_tester.p1_fighter_id'), yy, xx);
        yy += 30;
        _p1InputId = addInput(fighterData, yy, xx);
        yy += 30;

        var assistantData:Array = (
                function ():Array {
                    var data:Array = [];

                    var assistantObj:Object = AssisterModel.I.getAllAssisters();
                    for each (var assistant:FighterVO in assistantObj) {
                        data.push({text: assistant.id});
                    }

                    data.sort(function (a:Object, b:Object):int {
                        if (a[KEY] > b[KEY]) {
                            return 1;
                        }
                        else if (a[KEY] < b[KEY]) {
                            return -1;
                        }

                        return 0;
                    });

                    return data;
                }
        )();
        addLabel(GetLang('dev.txt.fighter_tester.p1_assistant_id'), yy, xx);
        yy += 30;
        _p1FzInputId = addInput(assistantData, yy, xx);
        yy += 30;

        addLabel(GetLang('dev.txt.fighter_tester.p2_fighter_id'), yy);
        yy += 30;
        _p2InputId = addInput(fighterData, yy, xx);
        yy += 30;

        addLabel(GetLang('dev.txt.fighter_tester.p2_assistant_id'), yy);
        yy += 30;
        _p2FzInputId = addInput(assistantData, yy, xx);
        yy += 30;

        var mapData:Array = (
                function ():Array {
                    var data:Array = [];

                    var mapObj:Object = MapModel.I.getAllMaps();
                    for each (var map:MapVO in mapObj) {
                        data.push({text: map.id});
                    }

                    data.sort(function (a:Object, b:Object):int {
                        if (a[KEY] > b[KEY]) {
                            return 1;
                        }
                        else if (a[KEY] < b[KEY]) {
                            return -1;
                        }

                        return 0;
                    });

                    return data;
                }
        )();
        addLabel(GetLang('dev.txt.fighter_tester.map_id'), yy, xx);
        yy += 30;
        _mapInputId = addInput(mapData, yy, xx);
        yy += 45;

        var fpsData:Array = [
            {
                text: '30'
            }, {
                text: '60'
            }
        ];
        addLabel(GetLang('dev.txt.fighter_tester.game_fps'), yy, xx);
        yy += 30;
        //	_fpsInput = addInput(GameConfig.FPS_GAME.toString(),yy,60);
        _fpsInput = addInput(fpsData, yy, xx);
        yy += 30;

        var recoverData:Array = [
            {
                text: GetLang('txt.options.enable')
            }, {
                text: GetLang('txt.options.disable')
            }
        ];
        addLabel(GetLang('dev.txt.fighter_tester.training_recover'), yy, xx);
        yy += 30;
        _autoReceiveHp = addInput(recoverData, yy, xx);
        yy += 30;

        _debugText                  = addLabel(GetLang('dev.txt.fighter_tester.error_message_prompt'), yy, xx);
        _debugText.width            = CONTROL_WIDTH;
        _debugText.height           = 200;
        _debugText.textFormat.color = 0xff0000;
        _debugText.wordWrap         = true;

//			addButton("改变FPS",400,50,100,30,changeFPS);
        addButton(GetLang('dev.txt.fighter_tester.btn_test'), 560, bx, BUTTON_WIDTH, 30, testGame);
        addButton('显示判定面', 520, bx, BUTTON_WIDTH, 30, renderMainClickHandler);

        var saveObj:Object = KyoSharedObject.load('fighter_test_config');
        if (saveObj && saveObj.p1) {

            function setCurrentItem(listView:PopUpListView, id:String):void {
                var index:int = -1;

                for (var i:int = 0; i < listView.dataProvider.length; ++i) {
                    var o:Object = listView.dataProvider.get(i);
                    if (o[KEY] == id) {
                        index = i;
                        break;
                    }
                }

                listView.selectedItem = listView.dataProvider.get(index);
            }


            setCurrentItem(_p1InputId, saveObj.p1.id);

            setCurrentItem(_p2InputId, saveObj.p2.id);

            if (saveObj.p1.fz) {
                setCurrentItem(_p1FzInputId, saveObj.p1.fz);
            }

            if (saveObj.p2.fz) {
                setCurrentItem(_p2FzInputId, saveObj.p1.fz);
            }

            if (saveObj.map) {
                setCurrentItem(_mapInputId, saveObj.map);
            }

        }

        openDebugWindow();
    }

    /**
     * 打开吸附于主窗口右侧的调试面板窗口。
     */
    private function openDebugWindow():void {
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.type         = NativeWindowType.NORMAL;
        options.systemChrome = NativeWindowSystemChrome.STANDARD;
        // 与 app.xml 主窗 renderMode=gpu 一致，否则 NativeWindow 抛 #1508
        options.renderMode   = NativeWindowRenderMode.GPU;
        options.transparent  = false;
        options.resizable    = false;
        options.maximizable  = false;
        options.minimizable  = false;

        _debugWindow                 = new NativeWindow(options);
        _debugWindow.title           = 'Debug';
        _debugWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
        _debugWindow.stage.align     = StageAlign.TOP_LEFT;
        _debugWindow.stage.color     = 0x333333;
        _debugWindow.stage.addChild(_testUI);

        _debugWindow.width  = DEBUG_PANEL_WIDTH;
        _debugWindow.height = DEBUG_PANEL_HEIGHT;
        _debugWindow.activate();

        // 按系统边框修正，使内容区达到面板设计尺寸
        var chromeW:Number = _debugWindow.width - _debugWindow.stage.stageWidth;
        var chromeH:Number = _debugWindow.height - _debugWindow.stage.stageHeight;
        _debugWindow.width  = DEBUG_PANEL_WIDTH + chromeW;
        _debugWindow.height = DEBUG_PANEL_HEIGHT + chromeH;

        dockDebugWindow();
        layoutDebugContent();

        var mainWin:NativeWindow = stage.nativeWindow;
        mainWin.addEventListener(NativeWindowBoundsEvent.MOVE, onMainWindowBoundsChange);
        mainWin.addEventListener(NativeWindowBoundsEvent.RESIZE, onMainWindowBoundsChange);
        mainWin.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
                onMainWindowDisplayStateChange
        );
        mainWin.addEventListener(Event.CLOSING, onMainWindowClosing);
        _debugWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onDebugWindowBoundsChange);
    }

    /**
     * 将调试窗口吸附到主窗口右侧并对齐高度。
     */
    private function dockDebugWindow():void {
        if (!_debugWindow || _debugWindow.closed || _docking) {
            return;
        }

        var mainWin:NativeWindow = stage.nativeWindow;
        var dockX:Number         = mainWin.x + mainWin.width;
        var dockY:Number         = mainWin.y;

        _docking = true;
        _debugWindow.height = mainWin.height;
        _debugWindow.x      = dockX;
        _debugWindow.y      = dockY;
        _docking = false;

        layoutDebugContent();
    }

    /**
     * 将调试面板组件在窗口内容区内居中。
     */
    private function layoutDebugContent():void {
        if (!_testUI || !_testContent || !_debugWindow || _debugWindow.closed) {
            return;
        }

        var sw:Number = _debugWindow.stage.stageWidth;
        var sh:Number = _debugWindow.stage.stageHeight;

        _testUI.graphics.clear();
        _testUI.graphics.beginFill(0x333333, 1);
        _testUI.graphics.drawRect(0, 0, sw, sh);
        _testUI.graphics.endFill();

        _testContent.x = (sw - DEBUG_PANEL_WIDTH) * 0.5;
        _testContent.y = Math.max(0, (sh - CONTENT_BOTTOM) * 0.5);
    }

    private function onMainWindowBoundsChange(e:NativeWindowBoundsEvent):void {
        dockDebugWindow();
    }

    private function onDebugWindowBoundsChange(e:NativeWindowBoundsEvent):void {
        dockDebugWindow();
    }

    private function onMainWindowDisplayStateChange(e:NativeWindowDisplayStateEvent):void {
        if (!_debugWindow || _debugWindow.closed) {
            return;
        }

        if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
            _debugWindow.visible = false;
        }
        else {
            _debugWindow.visible = true;
            dockDebugWindow();
        }
    }

    private function onMainWindowClosing(e:Event):void {
        if (_debugWindow && !_debugWindow.closed) {
            _debugWindow.close();
        }
    }

    private function addLabel(txt:String, y:Number = 0, x:Number = 0):Label {
        Theme.setTheme(_theme);
        var label:Label = new Label(txt);

        var tf:TextFormat = new TextFormat();

        tf.size  = 14;
        tf.color = 0xffffff;
        tf.font  = FONT.fontName;

        label.textFormat   = tf;
        label.x            = x;
        label.y            = y;
        label.mouseEnabled = false;

        _testContent.addChild(label);
        return label;
    }

    private function addInput(data:Array = null, y:Number = 0, x:Number = 0):PopUpListView {
        var listView:PopUpListView = new PopUpListView();

        if (data) {
            listView.dataProvider = new ArrayCollection(data);
        }
        listView.itemToText = function (item:*):String {
            return item[KEY];
        };

        listView.x      = x;
        listView.y      = y;
        listView.width  = CONTROL_WIDTH;
        listView.height = 27;

        _testContent.addChild(listView);
        return listView;
    }

    private function addButton(
            label:String, y:Number = 0, x:Number = 0, width:Number = 100, height:Number = 50,
            click:Function = null
    ):Sprite {
        var btn:Button = new Button(label);
        btn.x          = x;
        btn.y          = y;
        btn.width      = width;
        btn.height     = height;

        if (click != null) {
            btn.addEventListener(MouseEvent.CLICK, click);
        }

        _testContent.addChild(btn);
        return btn;
    }

    private function onDebugLog(msg:String):void {
        _debugText.text = msg;
    }

    private function changeFPS(...params):void {
        var fps:int = int(_fpsInput.selectedItem[KEY]);

        GameConfig.setGameFps(fps);
        stage.frameRate = fps;
    }

    /**
     * 点击测试游戏
     */
    private function testGame(...params):void {
        _debugText.text = '';

        var p1FighterId:String, p2FighterId:String;
        var p1AssistantId:String, p2AssistantId:String;
        var mapId:String;

        p1FighterId = _p1InputId.selectedItem[KEY];
        p2FighterId = _p2InputId.selectedItem[KEY];

        p1AssistantId = _p1FzInputId.selectedItem[KEY];
        p2AssistantId = _p2FzInputId.selectedItem[KEY];

        mapId = _mapInputId.selectedItem[KEY];

        KyoSharedObject.save('fighter_test_config', {
            p1: {id: p1FighterId, fz: p1AssistantId},
            p2: {id: p2FighterId, fz: p2AssistantId},

            map: mapId
        });

        changeFPS();

        GameMode.currentMode = GameMode.TRAINING;

        TrainingCtrler.RECOVER_HP = _autoReceiveHp.selectedItem[KEY] == '启用';

        GameData.I.p1Select          = new SelectVO();
        GameData.I.p2Select          = new SelectVO();
        GameData.I.p1Select.fighter1 = p1FighterId;
        GameData.I.p2Select.fighter1 = p2FighterId;
        GameData.I.p1Select.fuzhu    = p1AssistantId;
        GameData.I.p2Select.fuzhu    = p2AssistantId;
        GameData.I.selectMap         = mapId;

        Trace(
                'FighterTester: p1={p1FighterId}, assist1={p1AssistantId}, p2={p2FighterId}, assist2={p2AssistantId}, map={mapId}',
                {
                    p1FighterId  : p1FighterId,
                    p1AssistantId: p1AssistantId,
                    p2FighterId  : p2FighterId,
                    p2AssistantId: p2AssistantId,
                    mapId        : mapId
                }
        );
        loadGame();
    }

    private function loadGame():void {
        var ls:LoadingStage = new LoadingStage();
        MainGame.stageCtrl.goStage(ls, true);
    }

    private function initMusouFighters():void {

    }

    private function initialize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initialize);
        STAGE = stage;

        // 开启调试模式
        GameConfig.DEBUG_MODE = true;

        stage.stageFocusRect = false;

//			ResUtils.I.createDisplayObject(ResUtils.I.title , 'stg_title');

        initMusouFighters();

        _gameSprite = new Sprite();
        addChild(_gameSprite);
        _gameSprite.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);


        ResUtils.swfLib = new SwfLib();
        AssetManager.I.setAssetLoader(_assetLoader);
        GameInterface.instance = new GameInterfaceManager();

        trace('AssetManager.I.setAssetLoader');

        GameData.I.config.AI_level     = 1;
        GameData.I.config.quality      = GameQuality.LOW;
        GameData.I.config.keyInputMode = 1;

        _mainGame = new MainGame();
        _mainGame.initlize(_gameSprite, stage, function ():void {
            _mainGame.goLanguage(function ():void {
                var hash:String = GithubUtils.getCommitsHash();
                Debugger.showCommitHash(hash, GithubUtils.getCommitsDisplayLabel());

                _theme          = new SteelTheme();
                _theme.fontName = FONT.fontName;
                Theme.setTheme(_theme);

                UIUtils.LOCK_FONT = FONT.fontName;

                GameData.I.saveData();
                _mainGame.initalizeLoad(initBackHandler, initFailHandler);
            });

        }, initFailHandler);

        // 跳过黑屏遮盖
        StateCtrl.I.transEnabled = false;


        Debugger.initDebug(stage);
        Debugger.onErrorMsgCall = onDebugLog;
    }

    private function renderMainClickHandler(e:MouseEvent):void {
        var btn:Button = e.target as Button;
        if (!btn) {
            return;
        }

        if (DebugMain.I.isRender) {
            btn.text = '显示判定面';
        }
        else {
            DebugMain.I.initialize();
            btn.text = '隐藏判定面';
        }

        DebugMain.I.isRender = !DebugMain.I.isRender;
    }
}
}
