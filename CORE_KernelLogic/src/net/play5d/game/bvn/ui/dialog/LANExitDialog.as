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

package net.play5d.game.bvn.ui.dialog {
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.interfaces.lan.ILanExitDialog;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.SetBtnGroup;

/**
 * 联机对局 ESC 退出确认对话框。
 *
 * <p>会话状态与退出动作由壳经构造参数注入，避免 Kernel 依赖壳联机控制器。</p>
 *
 * @see net.play5d.game.bvn.interfaces.lan.ILanExitDialog
 */
public class LANExitDialog extends Sprite implements ILanExitDialog {
    /**
     * @param isClientActive 无参，客户端会话是否激活。
     * @param isServerActive 无参，服务端会话是否激活。
     * @param onClientEnd 无参，客户端结束联机。
     * @param onServerQuit 无参，服务端退出联机。
     * @example
     * <listing version="3.0">
     * var d:LANExitDialog = new LANExitDialog(
     *     function ():Boolean { return clientActive; },
     *     function ():Boolean { return serverActive; },
     *     function ():void { clientEnd(); },
     *     function ():void { serverQuit(); }
     * );
     * </listing>
     */
    public function LANExitDialog(
            isClientActive:Function,
            isServerActive:Function,
            onClientEnd:Function,
            onServerQuit:Function
    ) {
        _isClientActive = isClientActive;
        _isServerActive = isServerActive;
        _onClientEnd    = onClientEnd;
        _onServerQuit   = onServerQuit;

        _bg = new Sprite();
        _bg.graphics.beginFill(0, 0.5);
        _bg.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
        _bg.graphics.endFill();

        addChild(_bg);

        _btnGroup = new SetBtnGroup();
        _btnGroup.setBtnData([
                                 {label: 'CONTINUE', cn: GetLang('txt.common.continue')},
                                 {label: 'EXIT', cn: GetLang('txt.lan_exit_dialog.exit')}
                             ], 0);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);

        if (_isClientActive != null && _isClientActive()) {
            _btnGroup.gameInputType = GameInputType.P2;
        }

        if (_isServerActive != null && _isServerActive()) {
            _btnGroup.gameInputType = GameInputType.P1;
        }

        addChild(_btnGroup);
    }

    /** @private */
    private var _bg:Sprite;
    /** @private */
    private var _btnGroup:SetBtnGroup;
    /** @private */
    private var _isClientActive:Function;
    /** @private */
    private var _isServerActive:Function;
    /** @private */
    private var _onClientEnd:Function;
    /** @private */
    private var _onServerQuit:Function;

    /**
     * @inheritDoc
     */
    public function destroy():void {
        if (_btnGroup) {
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
            _btnGroup.destroy();
            _btnGroup = null;
        }
    }

    /**
     * @inheritDoc
     */
    public function isShowing():Boolean {
        return visible;
    }

    /**
     * @inheritDoc
     */
    public function show():void {
        this.visible        = true;
        _btnGroup.keyEnable = true;
        _btnGroup.setArrowIndex(0);
    }

    /**
     * @inheritDoc
     */
    public function hide():void {
        this.visible        = false;
        _btnGroup.keyEnable = false;
    }

    /** @private */
    private function btnGroupSelectHandler(e:SetBtnEvent):void {
        if (GameUI.showingDialog()) {
            return;
        }
        switch (e.selectedLabel) {
        case 'EXIT':
            if (_isServerActive != null && _isServerActive() && _onServerQuit != null) {
                _onServerQuit();
            }
            if (_isClientActive != null && _isClientActive() && _onClientEnd != null) {
                _onClientEnd();
            }
            break;
        case 'CONTINUE':
            hide();
            break;
        }
    }
}
}
