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

package net.play5d.game.bvn.stage {
import com.greensock.TweenLite;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.KeyConfigVO;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.interfaces.IInnerSetUI;
import net.play5d.game.bvn.ui.SetBtnGroup;
import net.play5d.game.bvn.ui.SetCtrlBtnUI;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

public class SettingStage implements IStage {
    include '../../../../../../include/_INCLUDE_.as';

    public function SettingStage() {
    }
    private var _ui:stg_set_ui;
    private var _btnGroup:SetBtnGroup;
    private var _innerSetUI:IInnerSetUI;
    private var _man:MovieClip;
    [Embed(source='/../assets/cancel.png')]
    private var _backMenuPicClass:Class;
    private var _backMenuBtn:Sprite;
    private var _oldConfig:ConfigVO;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 构建
     */
    public function build():void {
//			_oldConfig = ObjectUtils.cloneObject(GameData.I.config);
        _oldConfig = GameData.I.config.clone() as ConfigVO;

        _ui              = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting, ResUtils.SETTING);
        _btnGroup        = new SetBtnGroup();
        _btnGroup.startY = 30;
        _btnGroup.endY   = 550;
        _btnGroup.gap    = 70;
        _btnGroup.initMainSet();
        _btnGroup.initScroll(GameConfig.GAME_SIZE.x, 600);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnSelect);
        _btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);

        _ui.addChild(_btnGroup);

        if (GameConfig.TOUCH_MODE) {
            initBackBtn();
        }

        _man = _ui.ichigo;

        SoundCtrl.I.BGM(AssetManager.I.getSound('back'));
    }

    public function goInnerSetPage(innerUI:IInnerSetUI):void {
        function tweenComplete():void {
            _btnGroup.visible = false;
        }

        destoryInnerSetUI();

        _innerSetUI = innerUI;

        innerUI.addEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
        innerUI.addEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);

        _ui.addChild(innerUI.getUI());
        innerUI.fadIn();

        TweenLite.to(_btnGroup, 0.2, {y: -GameConfig.GAME_SIZE.y, onComplete: tweenComplete});

        _btnGroup.keyEnable = false;

        _man.gotoAndPlay('key_fadin');
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        if (_btnGroup) {
            try {
                _ui.removeChild(_btnGroup);
            }
            catch (e:Error) {
            }
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, onBtnSelect);
            _btnGroup.removeEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
            _btnGroup.destory();
            _btnGroup = null;
        }
        destoryInnerSetUI();
    }

    private function initBackBtn():void {
        if (!_backMenuBtn) {
            _backMenuBtn         = new Sprite();
            var btnBitmap:Bitmap = new _backMenuPicClass();
            btnBitmap.width      = 100;
            btnBitmap.smoothing  = true;
            btnBitmap.scaleY     = btnBitmap.scaleX;
            _backMenuBtn.addChild(btnBitmap);

            if (GameConfig.TOUCH_MODE) {
                _backMenuBtn.addEventListener(TouchEvent.TOUCH_TAP, backMenuHandler);
            }
            else {
                _backMenuBtn.addEventListener(MouseEvent.CLICK, backMenuHandler);
            }
        }
        _ui.addChild(_backMenuBtn);
    }

    private function goKeyConfig(player:int, key:KeyConfigVO):void {

        var setBtnUI:SetCtrlBtnUI = new SetCtrlBtnUI();
        setBtnUI.setKey(key);

        goInnerSetPage(setBtnUI);
    }

    private function destoryInnerSetUI():void {
        if (_innerSetUI) {
            try {
                _ui.removeChild(_innerSetUI.getUI());
            }
            catch (e:Error) {
            }
            _innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
            _innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
            _innerSetUI.destory();
            _innerSetUI = null;
        }

        _oldConfig = null;
    }

    private function goMainSetting():void {
        function tweenComplete():void {
            _btnGroup.keyEnable = true;
        }

        TweenLite.to(_btnGroup, 0.2, {y: 0, onComplete: tweenComplete, delay: 0.1});

        _btnGroup.visible = true;

        if (_innerSetUI) {
            _innerSetUI.fadOut();
            _innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
            _innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
        }
        _man.gotoAndPlay('key_fadout');

    }

    private function innerSetHandler(v:String):void {
        goMainSetting();
    }

    private function backMenuHandler(e:Event):void {
        GameData.I.saveData();
        GameData.I.config.applyConfig();
        GameInputer.updateConfig();
        MainGame.I.goMenu();
    }

    private function onOptionChange(e:SetBtnEvent):void {
        var config:ConfigVO = GameData.I.config;
        config.setValueByKey(e.optionKey, e.optionValue);
    }

    private function onBtnSelect(e:SetBtnEvent):void {
        switch (e.selectedLabel) {
        case 'P1 KEY SET':
            goKeyConfig(1, GameData.I.config.key_p1);
            break;
        case 'P2 KEY SET':
            goKeyConfig(2, GameData.I.config.key_p2);
            break;
        case 'CANCEL':
            GameData.I.config = _oldConfig;
            MainGame.I.goMenu();
            break;
        case 'APPLY':
            GameData.I.saveData();
            GameData.I.config.applyConfig();
            GameInputer.updateConfig();
            MainGame.I.goMenu();
            break;
        }
    }
}
}
