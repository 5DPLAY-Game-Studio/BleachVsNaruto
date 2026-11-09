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

package net.play5d.game.bvn.ui {
import flash.display.Sprite;

import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.ui.settings.SetBtnGroup;

/**
 * 继续按钮。再次登记点击时会换成新回调，监听只加一次。
 */
public class ContinueBtn extends Sprite {

    /**
     * 放上一个继续按钮。
     */
    public function ContinueBtn() {
        super();

        _btnGroup        = new SetBtnGroup();
        _btnGroup.startX = 0;
        _btnGroup.startY = 0;
        _btnGroup.setBtnData([
                                 {label: 'CONTINUE', cn: GetLang('common.continue')}
                             ], 2);
        addChild(_btnGroup);
    }
    private var _btnGroup:SetBtnGroup;
    private var _onClick:Function;

    /**
     * 记下点击回调。已经听过选择事件时不再加第二次。回调为 null 时，按下什么都不调用。
     *
     * @param callBack 回调，参数是这个按钮。
     * @example
     * <listing version="3.0">
     * btn.onClick(onContinue);
     * </listing>
     */
    public function onClick(callBack:Function):void {
        _onClick = callBack;
        if (_btnGroup.hasEventListener(SetBtnEvent.SELECT)) {
            return;
        }
        _btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnClick);
    }

    /**
     * 释放内部按钮组。不从父级移除自己。
     *
     * @example
     * <listing version="3.0">
     * btn.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_btnGroup) {
            _btnGroup.destroy();
        }
    }

    private function onBtnClick(e:SetBtnEvent):void {
        if (_onClick != null) {
            _onClick(this);
        }
    }
}
}
