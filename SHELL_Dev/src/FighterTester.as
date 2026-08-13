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
import feathers.controls.TextArea;
import feathers.data.ArrayCollection;
import feathers.style.Theme;
import feathers.text.TextFormat;
import feathers.themes.steel.SteelTheme;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
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
import net.play5d.game.bvn.debug.DebugSpriteBounds;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.test.DebugThemeChrome;
import net.play5d.game.bvn.test.DockedDebugWindow;
import net.play5d.game.bvn.test.SpriteInspectorWindow;
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

    /** @private 调试面板内容宽（左右分栏） */
    private static const DEBUG_PANEL_WIDTH:Number = 400;
    /** @private 调试面板内容高 */
    private static const DEBUG_PANEL_HEIGHT:Number = 600;
    /** @private 列内边距 */
    private static const COL_PAD:Number = 10;
    /** @private 左右列间距 */
    private static const COL_GAP:Number = 10;
    /** @private 单列宽 */
    private static const COL_WIDTH:Number = 185;
    /** @private 下拉/输入控件宽 */
    private static const CONTROL_WIDTH:Number = 175;
    /** @private 按钮宽 */
    private static const BUTTON_WIDTH:Number = 175;
    /** @private 左栏标签行高 */
    private static const LABEL_HEIGHT:Number = 22;
    /** @private 左栏字段组数（标签+下拉） */
    private static const FIELD_COUNT:int = 7;
    /** @private 右栏功能按钮数（不含底部测试） */
    private static const SIDE_BUTTON_COUNT:int = 3;
    /** @private 右栏功能按钮高 */
    private static const SIDE_BUTTON_HEIGHT:Number = 34;
    /** @private 右栏功能按钮行距 */
    private static const BUTTON_GAP:Number = 10;
    /** @private 底部测试按钮高 */
    private static const TEST_BUTTON_HEIGHT:Number = 40;
    /** @private 底部测试按钮与上方内容间距 */
    private static const TEST_BUTTON_GAP:Number = 10;

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
    /** @private Feathers 全局暗色；写入 fighter_test_config */
    private var _darkMode:Boolean = true;
    private var _mainGame:MainGame;
    private var _testUI:Sprite;
    private var _testContent:Sprite;
    /** @private 左栏：下拉列表 */
    private var _leftCol:Sprite;
    /** @private 右栏：功能按钮 + 错误 TextArea */
    private var _rightCol:Sprite;
    /** @private 底部通栏测试按钮 */
    private var _testBtn:Button;
    private var _debugWindow:DockedDebugWindow;
    private var _spriteInspector:SpriteInspectorWindow;
    private var _themeBtn:Button;
    private var _p1InputId:PopUpListView;
    private var _p2InputId:PopUpListView;
    private var _p1FzInputId:PopUpListView;
    private var _p2FzInputId:PopUpListView;
    private var _autoReceiveHp:PopUpListView;
    private var _mapInputId:PopUpListView;
    private var _fpsInput:PopUpListView;
    /** @private 右栏下半：错误信息多行文本 */
    private var _debugText:TextArea;

    private var _gameSprite:Sprite;
    private var _assetLoader:AssetLoader = new AssetLoader();

    private function initBackHandler():void {
        buildTestUI();
    }

    private function initFailHandler(msg:String):void {

    }

    private function buildTestUI():void {
        _testUI      = new Sprite();
        _testContent = new Sprite();
        _leftCol     = new Sprite();
        _rightCol    = new Sprite();
        _leftCol.x   = COL_PAD;
        _leftCol.y   = COL_PAD;
        _rightCol.x  = COL_PAD + COL_WIDTH + COL_GAP;
        _rightCol.y  = COL_PAD;
        _testContent.addChild(_leftCol);
        _testContent.addChild(_rightCol);
        _testUI.addChild(_testContent);

        var colH:Number  = DEBUG_PANEL_HEIGHT - COL_PAD * 2;
        var mainH:Number = colH - TEST_BUTTON_HEIGHT - TEST_BUTTON_GAP;
        var lx:Number    = (COL_WIDTH - CONTROL_WIDTH) * 0.5;
        var bx:Number    = (COL_WIDTH - BUTTON_WIDTH) * 0.5;
        var fieldSlot:Number = mainH / FIELD_COUNT;
        var halfH:Number     = mainH * 0.5;
        var btnH:Number      = SIDE_BUTTON_HEIGHT;
        var stackH:Number    = btnH * SIDE_BUTTON_COUNT + BUTTON_GAP * (SIDE_BUTTON_COUNT - 1);
        // 上半区垂直居中按钮组，上下留白
        var by:Number = Math.max(BUTTON_GAP, (halfH - stackH) * 0.5);

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
        _p1InputId = addField(
                GetLang('dev.txt.fighter_tester.p1_fighter_id'),
                fighterData,
                0,
                fieldSlot,
                lx
        );

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
        _p1FzInputId = addField(
                GetLang('dev.txt.fighter_tester.p1_assistant_id'),
                assistantData,
                1,
                fieldSlot,
                lx
        );
        _p2InputId = addField(
                GetLang('dev.txt.fighter_tester.p2_fighter_id'),
                fighterData,
                2,
                fieldSlot,
                lx
        );
        _p2FzInputId = addField(
                GetLang('dev.txt.fighter_tester.p2_assistant_id'),
                assistantData,
                3,
                fieldSlot,
                lx
        );

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
        _mapInputId = addField(
                GetLang('dev.txt.fighter_tester.map_id'),
                mapData,
                4,
                fieldSlot,
                lx
        );

        var fpsData:Array = [
            {
                text: '30'
            }, {
                text: '60'
            }
        ];
        _fpsInput = addField(
                GetLang('dev.txt.fighter_tester.game_fps'),
                fpsData,
                5,
                fieldSlot,
                lx
        );

        var recoverData:Array = [
            {
                text: GetLang('txt.options.enable')
            }, {
                text: GetLang('txt.options.disable')
            }
        ];
        _autoReceiveHp = addField(
                GetLang('dev.txt.fighter_tester.training_recover'),
                recoverData,
                6,
                fieldSlot,
                lx
        );

        _themeBtn = addButton(themeButtonLabel(), by, bx, BUTTON_WIDTH, btnH, onThemeButtonClick);
        by += btnH + BUTTON_GAP;
        addButton('显示判定面', by, bx, BUTTON_WIDTH, btnH, renderMainClickHandler);
        by += btnH + BUTTON_GAP;
        addButton('显示精灵框', by, bx, BUTTON_WIDTH, btnH, renderSpriteBoundsClickHandler);

        // 错误区占下半；初次用正文显示提示，点测试后清空，之后只承接 Debugger
        _debugText          = new TextArea();
        _debugText.editable = false;
        _debugText.x        = bx;
        _debugText.y        = halfH;
        _debugText.width    = BUTTON_WIDTH;
        _debugText.height   = halfH;
        _rightCol.addChild(_debugText);
        applyDebugTextAreaStyle();
        setDebugLogText(GetLang('dev.txt.fighter_tester.error_message_prompt'));

        _testBtn        = new Button(GetLang('dev.txt.fighter_tester.btn_test'));
        _testBtn.x      = COL_PAD;
        _testBtn.y      = COL_PAD + mainH + TEST_BUTTON_GAP;
        _testBtn.width  = DEBUG_PANEL_WIDTH - COL_PAD * 2;
        _testBtn.height = TEST_BUTTON_HEIGHT;
        _testBtn.addEventListener(MouseEvent.CLICK, testGame);
        _testContent.addChild(_testBtn);

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
                setCurrentItem(_p2FzInputId, saveObj.p2.fz);
            }

            if (saveObj.map) {
                setCurrentItem(_mapInputId, saveObj.map);
            }

        }

        _debugWindow                  = new DockedDebugWindow(stage.nativeWindow);
        _debugWindow.onDarkModeChange = onDebugDarkModeChange;
        _debugWindow.open(
                _testUI,
                _testContent,
                'Debug',
                DEBUG_PANEL_WIDTH,
                DEBUG_PANEL_HEIGHT,
                DEBUG_PANEL_HEIGHT,
                _theme,
                _darkMode
        );
        applyDebugLabelColors();
    }

    /**
     * 调试窗亮暗切换：同步全局 SteelTheme、属性窗，并写入 SharedObject。
     * @param darkMode 是否暗色。
     */
    private function onDebugDarkModeChange(darkMode:Boolean):void {
        _darkMode = darkMode;
        if (_theme) {
            _theme.darkMode = _darkMode;
            Theme.setTheme(_theme);
        }
        if (_themeBtn) {
            _themeBtn.text = themeButtonLabel();
        }
        applyDebugLabelColors();
        applyDebugTextAreaStyle();
        if (_spriteInspector) {
            _spriteInspector.setDarkMode(_darkMode);
        }
        persistDarkMode();
    }

    /**
     * 亮暗按钮文案（显示将切换到的模式）。
     * @return 按钮文字。
     */
    private function themeButtonLabel():String {
        return _darkMode ? '亮色' : '暗色';
    }

    /**
     * 右栏亮暗按钮：委托调试窗切换主题。
     * @param e 点击事件。
     */
    private function onThemeButtonClick(e:MouseEvent):void {
        if (_debugWindow) {
            _debugWindow.toggleDarkMode();
        }
    }

    /**
     * 按当前亮暗刷新调试面板 Label 颜色。
     */
    private function applyDebugLabelColors():void {
        if (!_leftCol) {
            return;
        }

        var tf:TextFormat = DebugThemeChrome.textFormat(_darkMode, false, 14);
        for (var i:int = 0; i < _leftCol.numChildren; i++) {
            var label:Label = _leftCol.getChildAt(i) as Label;
            if (!label) {
                continue;
            }
            label.textFormat = tf;
        }
    }

    /**
     * 错误信息 TextArea 使用红色正文格式。
     */
    private function applyDebugTextAreaStyle():void {
        if (!_debugText) {
            return;
        }

        var tf:TextFormat = DebugThemeChrome.textFormat(_darkMode, false, 14);
        tf.color              = 0xff0000;
        _debugText.textFormat = tf;
    }

    /**
     * 将 darkMode 合并写入 fighter_test_config。
     */
    private function persistDarkMode():void {
        var data:Object = KyoSharedObject.load('fighter_test_config');
        if (!data) {
            data = {};
        }

        KyoSharedObject.save('fighter_test_config', {
            p1      : data.p1,
            p2      : data.p2,
            map     : data.map,
            darkMode: _darkMode
        });
    }

    /**
     * 左栏按槽位平分高度放置标签+下拉。
     * @param txt 标签文案。
     * @param data 下拉数据。
     * @param index 槽位下标。
     * @param slotH 单槽高度。
     * @param x 控件 x。
     * @return 下拉列表。
     */
    private function addField(
            txt  :String,
            data :Array,
            index:int,
            slotH:Number,
            x    :Number
    ):PopUpListView {
        var y0:Number = index * slotH;
        addLabel(txt, y0, x);

        return addInput(data, y0 + LABEL_HEIGHT, x);
    }

    private function addLabel(txt:String, y:Number = 0, x:Number = 0):Label {
        var label:Label = new Label(txt);

        label.textFormat   = DebugThemeChrome.textFormat(_darkMode, false, 14);
        label.x            = x;
        label.y            = y;
        label.mouseEnabled = false;

        _leftCol.addChild(label);
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

        _leftCol.addChild(listView);
        return listView;
    }

    private function addButton(
            label:String, y:Number = 0, x:Number = 0, width:Number = 100, height:Number = 50,
            click:Function = null
    ):Button {
        var btn:Button = new Button(label);
        btn.x          = x;
        btn.y          = y;
        btn.width      = width;
        btn.height     = height;

        if (click != null) {
            btn.addEventListener(MouseEvent.CLICK, click);
        }

        _rightCol.addChild(btn);
        return btn;
    }

    private function onDebugLog(msg:String):void {
        setDebugLogText(msg);
    }

    /**
     * 写入/清空错误信息 TextArea。
     * <p>直接赋空串时 TextArea 视口偶发不刷新，清空时先脏写再置空。</p>
     * @param msg 错误文案；<code>null</code> 或空串表示清空。
     */
    private function setDebugLogText(msg:String):void {
        if (!_debugText) {
            return;
        }

        var next:String = (msg != null) ? msg : '';
        if (next.length == 0) {
            if (_debugText.text != null && _debugText.text.length > 0) {
                _debugText.text = ' ';
            }
            _debugText.text = '';

            return;
        }

        _debugText.text = next;
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
        setDebugLogText('');

        var p1FighterId:String, p2FighterId:String;
        var p1AssistantId:String, p2AssistantId:String;
        var mapId:String;

        p1FighterId = _p1InputId.selectedItem[KEY];
        p2FighterId = _p2InputId.selectedItem[KEY];

        p1AssistantId = _p1FzInputId.selectedItem[KEY];
        p2AssistantId = _p2FzInputId.selectedItem[KEY];

        mapId = _mapInputId.selectedItem[KEY];

        KyoSharedObject.save('fighter_test_config', {
            p1      : {id: p1FighterId, fz: p1AssistantId},
            p2      : {id: p2FighterId, fz: p2AssistantId},
            map     : mapId,
            darkMode: _darkMode
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

                var saveTheme:Object = KyoSharedObject.load('fighter_test_config');
                _darkMode = true;
                if (saveTheme && saveTheme.hasOwnProperty('darkMode')) {
                    _darkMode = Boolean(saveTheme.darkMode);
                }

                _theme          = new SteelTheme();
                _theme.darkMode = _darkMode;
                _theme.fontName = DebugThemeChrome.fontName();
                Theme.setTheme(_theme);

                UIUtils.LOCK_FONT = DebugThemeChrome.fontName();

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

    private function renderSpriteBoundsClickHandler(e:MouseEvent):void {
        var btn:Button = e.target as Button;
        if (!btn) {
            return;
        }

        if (DebugSpriteBounds.I.isRender) {
            btn.text = '显示精灵框';
            if (_spriteInspector) {
                _spriteInspector.stop();
            }
        }
        else {
            DebugSpriteBounds.I.initialize();
            btn.text = '隐藏精灵框';
            if (!_spriteInspector) {
                _spriteInspector = new SpriteInspectorWindow(stage.nativeWindow, _theme, _darkMode);
            }
            else {
                _spriteInspector.setDarkMode(_darkMode);
            }
            _spriteInspector.start();
        }

        DebugSpriteBounds.I.isRender = !DebugSpriteBounds.I.isRender;
    }
}
}
