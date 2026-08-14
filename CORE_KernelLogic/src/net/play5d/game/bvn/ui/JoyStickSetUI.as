/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ui {
import com.greensock.TweenLite;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.ui.GameInputDevice;

import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.input.JoyStickConfigVO;
import net.play5d.game.bvn.input.JoyStickSetVO;
import net.play5d.game.bvn.input.JoySticker;
import net.play5d.game.bvn.interfaces.IInnerSetUI;
import net.play5d.kyo.utils.WebUtils;

/**
 * 手柄按键设置页（设置内页）。
 *
 * <p>P1 应用配置时通过 <code>onApplyJoyConfig</code> 回调由壳持久化，避免 Kernel 依赖壳配置管理器。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IInnerSetUI
 * @see #onApplyJoyConfig
 */
public class JoyStickSetUI extends EventDispatcher implements IInnerSetUI {
    /**
     * 构造手柄设置 UI。
     * @example
     * <listing version="3.0">
     * var ui:JoyStickSetUI = new JoyStickSetUI();
     * ui.onApplyJoyConfig = persistJoy;
     * ui.setConfig(1, joyConfig);
     * </listing>
     */
    public function JoyStickSetUI() {
        _ui   = new Sprite();
        _bp   = new _joybitmap();
        _bp.x = 170;
        _bp.y = 250;
        _ui.addChild(_bp);

        _tmpJoyConfig = new JoyStickConfigVO();

        initKeyMapping();
    }

    /**
     * P1 点击 APPLY 且写入配置后调用（无参）。
     * <p>由壳注入；未设置时跳过。</p>
     */
    public var onApplyJoyConfig:Function;

    /** @private */
    [Embed(source='/../assets/setting_joy.png')]
    private var _joybitmap:Class;
    /** @private */
    private var _btnGroup:SetBtnGroup;
    /** @private */
    private var _player:int;
    /** @private */
    private var _ui:Sprite;
    /** @private */
    private var _bp:Bitmap;
    /** @private */
    private var _joyConfig:JoyStickConfigVO;
    /** @private */
    private var _tmpJoyConfig:JoyStickConfigVO;
    /** @private */
    private var _deviceId:String;
    /** @private */
    private var _setIndex:int;
    /** @private */
    private var _mappings:Array;
    /** @private */
    private var _dialog:SetBtnDialog;
    /** @private */
    private var _startSet:Boolean;

    /**
     * 绑定玩家序号与手柄配置。
     * @param player 玩家序号（1 / 2）。
     * @param vo 当前手柄配置。
     * @example
     * <listing version="3.0">
     * ui.setConfig(1, config);
     * </listing>
     */
    public function setConfig(player:int, vo:JoyStickConfigVO):void {
        _player    = player;
        _joyConfig = vo;
        _tmpJoyConfig.readObj(vo.toObj());
        _deviceId = _tmpJoyConfig.deviceId;
        initBtns();
    }

    /**
     * 入场动画。
     * @example
     * <listing version="3.0">
     * ui.fadIn();
     * </listing>
     */
    public function fadIn():void {
        _bp.y = 600;
        TweenLite.to(_bp, 0.3, {y: 240});
    }

    /**
     * 退场动画。
     * @example
     * <listing version="3.0">
     * ui.fadOut();
     * </listing>
     */
    public function fadOut():void {
        TweenLite.to(_ui, 0.3, {y: 600});
    }

    /**
     * 显示对象根节点。
     * @return UI 根。
     * @example
     * <listing version="3.0">
     * parent.addChild(ui.getUI());
     * </listing>
     */
    public function getUI():DisplayObject {
        return _ui;
    }

    /**
     * 销毁监听与按钮组。
     * @example
     * <listing version="3.0">
     * ui.destroy();
     * </listing>
     */
    public function destroy():void {
        GameRender.remove(renderSet);

        if (_btnGroup) {
            try {
                _ui.removeChild(_btnGroup);
            }
            catch (e:Error) {
            }

            _btnGroup.destroy();
            _btnGroup = null;
        }
    }

    /** @private */
    private static function subString(str:String, len:int):String {
        if (!str) {
            return null;
        }
        if (str.length < len) {
            return str;
        }

        return str.substr(0, len) + '...';
    }

    /** @private */
    private function initBtns():void {
        var joysticks:Vector.<GameInputDevice> = JoySticker.getAllDeivces();

        var joyOptions:Array = [{label: 'NONE', cn: GetLang('txt.joy_stick_set_ui.none'), value: null}];
        for (var i:int; i < joysticks.length; i++) {
            var di:GameInputDevice = joysticks[i];
            joyOptions.push({
                                label: subString(di.name, 15),
                                cn   : subString(di.name, 45),
                                value: di.id
                            });
        }

        _btnGroup        = new SetBtnGroup();
        _btnGroup.startY = 30;
        _btnGroup.setBtnData([
                                 {
                                     label      : 'USE JOY', cn: GetLang('txt.joy_stick_set_ui.use_joy'), options: joyOptions, optoinKey: 'deviceId',
                                     optionValue: _tmpJoyConfig.deviceId
                                 },
                                 {label: 'SET ALL', cn: GetLang('txt.common.set_all')},
                                 {label: 'SET DEFAULT', cn: GetLang('txt.common.set_default')},
                                 {label: 'BUY JOY', cn: GetLang('txt.joy_stick_set_ui.buy_joy')},
                                 {label: 'APPLY', cn: GetLang('txt.common.apply')},
                                 {label: 'CANCEL', cn: GetLang('txt.common.cancel')}
                             ]);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnSelect);
        _btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptoinChange);

        _ui.addChild(_btnGroup);
    }

    /** @private */
    private function renderSet():void {
        if (!_startSet) {
            if (JoySticker.isDownAnyKey(_tmpJoyConfig.deviceId) == false) {
                _startSet = true;
            }

            return;
        }

        var jv:JoyStickSetVO = JoySticker.getDownKey(_tmpJoyConfig.deviceId, true);
        if (jv) {
            var cur:Object = _mappings[_setIndex];
            if (cur) {
                _tmpJoyConfig[cur.id] = jv;
            }
            setNextKey();
        }
    }

    /** @private */
    private function initKeyMapping():void {
        _mappings = [
            {id: 'up2', name: 'UP roker', cn: GetLang('txt.joy_stick_set_ui.key_up2')},
            {id: 'down2', name: 'DOWN roker', cn: GetLang('txt.joy_stick_set_ui.key_down2')},
            {id: 'left2', name: 'LEFT roker', cn: GetLang('txt.joy_stick_set_ui.key_left2')},
            {id: 'right2', name: 'RIGHT roker', cn: GetLang('txt.joy_stick_set_ui.key_right2')},
            {id: 'up', name: 'UP button', cn: GetLang('txt.joy_stick_set_ui.key_up')},
            {id: 'down', name: 'DOWN button', cn: GetLang('txt.joy_stick_set_ui.key_down')},
            {id: 'left', name: 'LEFT button', cn: GetLang('txt.joy_stick_set_ui.key_left')},
            {id: 'right', name: 'RIGHT button', cn: GetLang('txt.joy_stick_set_ui.key_right')},
            {id: 'attack', name: 'ATTACK', cn: GetLang('txt.joy_stick_set_ui.key_attack')},
            {id: 'jump', name: 'JUMP', cn: GetLang('txt.joy_stick_set_ui.key_jump')},
            {id: 'dash', name: 'DASH', cn: GetLang('txt.joy_stick_set_ui.key_dash')},
            {id: 'skill', name: 'SKILL', cn: GetLang('txt.joy_stick_set_ui.key_skill')},
            {id: 'superSkill', name: 'SUPER SKILL', cn: GetLang('txt.joy_stick_set_ui.key_super_skill')},
            {id: 'special', name: 'SPECIAL', cn: GetLang('txt.joy_stick_set_ui.key_special')},
            {id: 'waikai', name: 'BANN KAI', cn: GetLang('txt.joy_stick_set_ui.key_waikai')},
            {id: 'back', name: 'BACK', cn: GetLang('txt.joy_stick_set_ui.key_back')},
            {id: 'select', name: 'SELECT', cn: GetLang('txt.joy_stick_set_ui.key_select')},
        ];
    }

    /** @private */
    private function setNextKey():void {
        _setIndex++;
        var km:Object = _mappings[_setIndex];
        if (km) {
            if (!_dialog) {
                _dialog = new SetBtnDialog();
                _ui.addChild(_dialog.ui);
            }

            _dialog.show(km.name, km.cn);
        }
        else {
            _dialog.hide();
            _btnGroup.keyEnable = true;
            GameRender.remove(renderSet);
        }
    }

    /** @private */
    private function onBtnSelect(e:SetBtnEvent):void {
        switch (e.selectedLabel) {
        case 'SET ALL':
            if (!JoySticker.isActive(_tmpJoyConfig.deviceId)) {
                GameUI.alert(
                    GetLang('alert.joy_stick_set_ui.no_joystick_title'),
                    GetLang('alert.joy_stick_set_ui.no_joystick')
                );

                return;
            }

            _setIndex           = -1;
            _btnGroup.keyEnable = false;
            _startSet           = false;
            GameRender.add(renderSet);
            setNextKey();
            break;
        case 'SET DEFAULT':
            _tmpJoyConfig          = new JoyStickConfigVO();
            _tmpJoyConfig.deviceId = _deviceId;
            GameUI.alert(
                GetLang('alert.joy_stick_set_ui.set_default_ok_title'),
                GetLang('alert.joy_stick_set_ui.set_default_ok')
            );
            break;
        case 'BUY JOY':
            WebUtils.getURL('http://bbs.1212321.com/forum.php?mod=viewthread&tid=110');
            break;
        case 'APPLY':
            _joyConfig.readObj(_tmpJoyConfig.toObj());
            if (_player == 1 && onApplyJoyConfig != null) {
                onApplyJoyConfig();
            }
            dispatchEvent(new SetBtnEvent(SetBtnEvent.APPLY_SET));
            break;
        case 'CANCEL':
            dispatchEvent(new SetBtnEvent(SetBtnEvent.CANCEL_SET));
            break;
        }
    }

    /** @private */
    private function onOptoinChange(e:SetBtnEvent):void {
        if (e.optionKey == 'deviceId') {
            _tmpJoyConfig.deviceId    = e.optionValue;
            _tmpJoyConfig.deviceIsSet = true;
            _deviceId                 = e.optionValue;
        }
    }
}
}
