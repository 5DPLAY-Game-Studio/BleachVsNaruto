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
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.test.GameInterfaceManager;
import net.play5d.game.bvn.test.SwfLib;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.game.bvn.utils.AssetLoader;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.KyoSharedObject;

//	import flash.text.TextFormat;

[SWF(width='1000', height='600', frameRate='30', backgroundColor='#000000')]
public class FighterTester extends Sprite {
    private const KEY:String = 'text';

    public function FighterTester() {
        // 忽略旧版角色
        GameStageLoadCtrl.IGNORE_OLD_FIGHTER = true;

        if (stage) {
            initlize();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, initlize);
        }
    }
    private var _theme:SteelTheme;
    private var _mainGame:MainGame;
    private var _testUI:Sprite;
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

    private function initBackHandler():void {
        buildTestUI();
    }

    private function initFailHandler(msg:String):void {

    }

    private function buildTestUI():void {
        _testUI   = new Sprite();
        _testUI.x = 810;
        _testUI.graphics.beginFill(0x333333, 1);
        _testUI.graphics.drawRect(-10, 0, 200, 600);
        _testUI.graphics.endFill();
        addChild(_testUI);

        var xx:Number = 0;
        var yy:Number = 0;

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
        _debugText.width            = 190;
        _debugText.height           = 200;
        _debugText.textFormat.color = 0xff0000;
        _debugText.wordWrap         = true;

//			addButton("改变FPS",400,50,100,30,changeFPS);
        addButton(GetLang('dev.txt.fighter_tester.btn_test'), 560, 3, 175, 30, testGame);

        var saveObj:Object = KyoSharedObject.load('fighter_test_config');
        if (saveObj && saveObj.p1) {
//				_p1InputId.text = saveObj.p1.id;
//				_p2InputId.text = saveObj.p2.id;
//
//				if(saveObj.p1.fz) _p1FzInputId.text = saveObj.p1.fz;
//				if(saveObj.p2.fz) _p2FzInputId.text = saveObj.p2.fz;
//				if(saveObj.map) _mapInputId.text = saveObj.map;

            //			trace(saveObj.p1.id, saveObj.p2.id, saveObj.p1.fz, saveObj.p2.fz, saveObj.map)


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
    }

    private function addLabel(txt:String, y:Number = 0, x:Number = 0):Label {
//			var label:TextField = new TextField();
//			var tf:TextFormat = new TextFormat();
//
//			tf.size = 14;
//			tf.color = 0xffffff;
//
//			label.defaultTextFormat = tf;
//			label.text = txt;
//			label.x = x;
//			label.y = y;
//			label.mouseEnabled = false;
//			_testUI.addChild(label);
//
//			return label;

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

        _testUI.addChild(label);
        return label;
    }

    private function addInput(data:Array = null, y:Number = 0, x:Number = 0):PopUpListView {
//			var label:TextField = new TextField();
//			var tf:TextFormat = new TextFormat();
//
//			tf.size = 14;
//			tf.color = 0x000000;
//
//			label.defaultTextFormat = tf;
//			label.text = txt;
//			label.x = x;
//			label.y = y;
//			label.width = 100;
//			label.height = 20;
//			label.backgroundColor = 0xffffff;
//			label.background = true;
//			label.type = TextFieldType.INPUT;
//			label.condenseWhite = true;
//			_testUI.addChild(label);


        var listView:PopUpListView = new PopUpListView();

        if (data) {
            listView.dataProvider = new ArrayCollection(data);
        }
        listView.itemToText = function (item:*):String {
            return item[KEY];
        };

//			listView.buttonFactory = DisplayObjectFactory.withFunction(function ():Button {
//				var button:Button = new Button();
//				var format:TextFormat = new TextFormat();
//				format.font = FONT.fontName;
//				button.textFormat = format;
//
//				return button;
//
//			});

        listView.x      = x;
        listView.y      = y;
        listView.width  = 182;
        listView.height = 27;

        _testUI.addChild(listView);
        return listView;
    }

    private function addButton(
            label:String, y:Number = 0, x:Number = 0, width:Number = 100, height:Number = 50,
            click:Function = null
    ):Sprite {
//			var btn:KyoSimpButton = new KyoSimpButton(label,width,height);
//			btn.x = x;
//			btn.y = y;
//
//			if(click != null) btn.onClick(click);
//			_testUI.addChild(btn);
//
//			return btn;

        var btn:Button = new Button(label);
        btn.x          = x;
        btn.y          = y;
        btn.width      = width;
        btn.height     = height;

        if (click != null) {
            btn.addEventListener(MouseEvent.CLICK, click);
        }

        _testUI.addChild(btn);
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

//			trace(_p1InputId.selectedItem[KEY])
//			//trace(_p1InputId.selectedItem[KEY])
//			trace(_p1InputId.dataProvider.get(0)[KEY])


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

        Trace(p1FighterId, p1FighterId, p1AssistantId, p1AssistantId, mapId);
        loadGame();
    }

    private function loadGame():void {
        var ls:LoadingStage = new LoadingStage();
        MainGame.stageCtrl.goStage(ls, true);
    }

    private function initMosouFighters():void {

    }

    private function initlize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initlize);

        // 开启调试模式
        GameConfig.DEBUG_MODE = true;

        stage.stageFocusRect = false;

//			ResUtils.I.createDisplayObject(ResUtils.I.title , 'stg_title');

        initMosouFighters();

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
}
}
