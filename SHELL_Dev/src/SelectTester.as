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
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.setTimeout;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.GameInterface;
import net.play5d.game.bvn.test.GameInterfaceManager;
import net.play5d.game.bvn.test.SwfLib;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.game.bvn.utils.AssetLoader;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.ui.KyoSimpButton;

[SWF(width='1000', height='600', frameRate='30', backgroundColor='#000000')]
public class SelectTester extends Sprite {
    public function SelectTester() {
        GameStageLoadCtrl.IGNORE_OLD_FIGHTER = true;

        if (stage) {
            initlize();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, initlize);
        }
    }
    private var _mainGame:MainGame;
    private var _testUI:Sprite;
    private var _modeText:TextField;
    private var _p2InputId:TextField;
    private var _p1FzInputId:TextField;
    private var _p2FzInputId:TextField;
    private var _autoReceiveHp:TextField;
    private var _mapInputId:TextField;
    private var _fpsInput:TextField;
    private var _debugText:TextField;

//		[Embed(source="/assets/font/font1.png")]
//		private var _font1:Class;
//
//		[Embed(source="/assets/font/font1.xml", mimeType="application/octet-stream"))]
//		private var _font1XML:Class;
    private var _gameSprite:Sprite;
    private var _assetLoader:AssetLoader = new AssetLoader();
    private var _box:Sprite;

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
//
        var yy:Number = 20;
        addLabel('Mode:', yy);
        _modeText = addInput('1', yy, 60);

        yy += 40;

        addButton('广告区域', yy, 50, 100, 50, toogleBox);


        addButton('测试', 500, 50, 100, 50, testGame);

    }

    private function addLabel(txt:String, y:Number = 0, x:Number = 0):TextField {
        var label:TextField = new TextField();

        var tf:TextFormat = new TextFormat();
        tf.size           = 14;
        tf.color          = 0xffffff;

        label.defaultTextFormat = tf;

        label.text         = txt;
        label.x            = x;
        label.y            = y;
        label.mouseEnabled = false;

        _testUI.addChild(label);

        return label;
    }

    private function addInput(txt:String, y:Number = 0, x:Number = 0):TextField {
        var label:TextField = new TextField();

        var tf:TextFormat = new TextFormat();
        tf.size           = 14;
        tf.color          = 0x000000;

        label.defaultTextFormat = tf;

        label.text            = txt;
        label.x               = x;
        label.y               = y;
        label.width           = 100;
        label.height          = 20;
        label.backgroundColor = 0xffffff;
        label.background      = true;
        label.type            = TextFieldType.INPUT;
        label.condenseWhite   = true;

        _testUI.addChild(label);

        return label;
    }

    private function addButton(label:String, y:Number = 0, x:Number = 0, width:Number = 100, height:Number = 50,
                               click:Function                                                              = null
    ):Sprite {

        var btn:KyoSimpButton = new KyoSimpButton(label, width, height);
        btn.x                 = x;
        btn.y                 = y;
        if (click != null) {
            btn.onClick(click);
        }
        _testUI.addChild(btn);

        return btn;
    }

    private function onDebugLog(msg:String):void {
        _debugText.text = msg;
    }

    private function testGame(...params):void {
        GameLogic.setGameMode(int(_modeText.text));
        MainGame.I.goLogo();
        GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;

        setTimeout(MainGame.I.goSelect, 2000);
    }

    private function initMosouFighters():void {

    }

    private function toogleBox(...params):void {
        if (!_box) {
            _box = new Sprite();
            _box.graphics.beginFill(0xff0000, 1);
            _box.graphics.drawRect(0, 0, 336, 280);
            _box.graphics.endFill();
            _box.visible = false;
            _box.addEventListener(MouseEvent.MOUSE_DOWN, boxMouseHandler);
            _box.addEventListener(MouseEvent.MOUSE_UP, boxMouseHandler);
        }

        if (!_box.visible) {
            _box.visible = true;

            _box.x = (
                             GameConfig.GAME_SIZE.x - 336
                     ) / 2;
            _box.y = (
                             GameConfig.GAME_SIZE.y - 280
                     ) / 2;

            MainGame.I.root.addChild(_box);
        }
        else {
            _box.visible = false;
        }

    }

    private function initlize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initlize);

        // 开启调试模式
        GameConfig.DEBUG_MODE = true;

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
                trace('字体名称：' + FONT.fontName);
                UIUtils.LOCK_FONT = FONT.fontName;

                GameData.I.saveData();
                _mainGame.initalizeLoad(initBackHandler, initFailHandler);
            });

        }, initFailHandler);

        StateCtrl.I.transEnabled = false;

        Debugger.initDebug(stage);
        Debugger.onErrorMsgCall = onDebugLog;
    }

    private function boxMouseHandler(e:MouseEvent):void {
        if (e.type == MouseEvent.MOUSE_DOWN) {
            (
                    e.currentTarget as Sprite
            ).startDrag(false);
        }
        else {
            (
                    e.currentTarget as Sprite
            ).stopDrag();
        }
    }

}
}
