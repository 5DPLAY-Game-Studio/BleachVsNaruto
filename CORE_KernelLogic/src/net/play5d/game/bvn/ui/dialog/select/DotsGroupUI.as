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

package net.play5d.game.bvn.ui.dialog.select {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;

import net.play5d.game.bvn.GameConfig;

/**
 * 一排分页点。页号从 1 起。再次 <code>update</code> 不摘掉旧点，只换内部数组。还没更新就按页刷新或销毁会抛错。
 */
public class DotsGroupUI extends Sprite {

    /**
     * 点被点到时调用，参数是页号。null 时点击什么都不做。
     *
     * @default null
     */
    public var onDotClick:Function;
    private var _dotArr:Array;

    /**
     * 按总数重建点数组并追加到自己身上。第一点选中。总数是 0 时数组变空，旧的点还留在显示列表里。
     *
     * @param total 点数。
     * @example
     * <listing version="3.0">
     * dots.update(4);
     * </listing>
     */
    public function update(total:int):void {
        _dotArr = [];

        for (var i:int; i < total; i++) {
            var dot:DotItemUI = new DotItemUI();
            dot.page          = i + 1;

            addChild(dot.getUI());

            _dotArr.push(dot);

            dot.getUI().x = i * 40;

            if (GameConfig.TOUCH_MODE) {
                dot.getUI().addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
            }
            else {
                dot.getUI().addEventListener(MouseEvent.CLICK, mouseHandler);
            }


            if (i == 0) {
                dot.focus(true);
            }
        }
    }

    /**
     * 只亮页号相同的点。还没 <code>update</code> 时抛错。
     *
     * @param v 页号。
     * @throws TypeError 点数组还不存在时。
     * @example
     * <listing version="3.0">
     * dots.updateByPage(1);
     * </listing>
     */
    public function updateByPage(v:int):void {
        for each(var d:DotItemUI in _dotArr) {
            d.focus(d.page == v);
        }
    }

    /**
     * 摘掉点和鼠标、触摸监听。点还留在显示列表里。还没更新时抛错。
     *
     * @throws TypeError 点数组还不存在时。
     * @example
     * <listing version="3.0">
     * dots.destroy();
     * </listing>
     */
    public function destroy():void {
        for each(var d:DotItemUI in _dotArr) {
            d.getUI().removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
            d.getUI().removeEventListener(MouseEvent.CLICK, mouseHandler);
        }
    }

    private function doClick(target:Object):void {
        if (onDotClick == null) {
            return;
        }

        var curUI:DisplayObject = target as DisplayObject;

        for each(var d:DotItemUI in _dotArr) {
            if (d.getUI() == curUI) {
                onDotClick(d.page);
            }
        }
    }

    private function mouseHandler(e:MouseEvent):void {
        doClick(e.currentTarget);
    }

    private function touchHandler(e:TouchEvent):void {
        doClick(e.currentTarget);
    }
}
}
