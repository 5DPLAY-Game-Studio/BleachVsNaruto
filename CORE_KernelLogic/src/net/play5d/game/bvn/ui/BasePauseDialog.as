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
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.ui.settings.SetBtnGroup;

/**
 * 暂停菜单对话框基类。
 *
 * <p>公共半透明背景、招式表与 CONTINUE；首项由子类通过
 * <code>handleExtraSelect</code> 处理。</p>
 *
 * @see PauseDialog
 * @see MusouPauseDialog
 */
public class BasePauseDialog extends Sprite {

    /**
     * @param btnData 按钮数据（首项因模式而异）。
     * @param closeConfirmOnHide 隐藏时是否关闭确认框。
     */
    public function BasePauseDialog(btnData:Array, closeConfirmOnHide:Boolean = false) {
        _closeConfirmOnHide = closeConfirmOnHide;

        _bg = new Sprite();
        _bg.graphics.beginFill(0, 0.5);
        _bg.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
        _bg.graphics.endFill();
        addChild(_bg);

        _btnGroup = new SetBtnGroup();
        _btnGroup.setBtnData(btnData, 2);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
        addChild(_btnGroup);
    }

    /** @private */
    protected var _btnGroup:SetBtnGroup;
    /** @private */
    private var _bg:Sprite;
    /** @private */
    private var _moveList:MoveListSp;
    /** @private */
    private var _closeConfirmOnHide:Boolean;

    /**
     * 释放按钮组与招式表。
     */
    public function destroy():void {
        if (_btnGroup) {
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
            _btnGroup.destroy();
            _btnGroup = null;
        }
        if (_moveList) {
            _moveList.destroy();
            _moveList = null;
        }
    }

    /**
     * 是否正在显示。
     *
     * @return 可见时为 true。
     */
    public function isShowing():Boolean {
        return visible;
    }

    /**
     * 显示并启用按键，默认选中 CONTINUE。
     */
    public function show():void {
        this.visible        = true;
        _btnGroup.keyEnable = true;
        _btnGroup.setArrowIndex(2);
    }

    /**
     * 隐藏对话框；若招式表打开则仅关闭招式表。
     *
     * @return 对话框本身已隐藏时为 true。
     */
    public function hide():Boolean {
        if (_moveList && _moveList.isShowing()) {
            hideMoveList();
            return false;
        }

        this.visible        = false;
        _btnGroup.keyEnable = false;
        if (_closeConfirmOnHide) {
            GameUI.closeConfrim();
        }

        return true;
    }

    /**
     * 处理 CONTINUE / MOVE LIST 之外的按钮。
     *
     * @param label 选中按钮 label。
     * @return 已处理时为 true。
     */
    protected function handleExtraSelect(label:String):Boolean {
        return false;
    }

    /** @private */
    private function showMoveList():void {
        if (!_moveList) {
            _moveList              = new MoveListSp();
            _moveList.onBackSelect = hideMoveList;
            addChild(_moveList);
        }

        _btnGroup.keyEnable = false;
        _moveList.show();
    }

    /** @private */
    private function hideMoveList():void {
        _moveList.hide();
        _btnGroup.keyEnable = true;
        GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, 'movelist-back');
    }

    /** @private */
    private function btnGroupSelectHandler(e:SetBtnEvent):void {
        if (GameUI.showingDialog()) {
            return;
        }
        if (handleExtraSelect(e.selectedLabel)) {
            return;
        }

        switch (e.selectedLabel) {
        case 'MOVE LIST':
            showMoveList();
            GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, 'movelist');
            break;
        case 'CONTINUE':
            GameCtrl.I.resume(true);
            break;
        }
    }
}
}
