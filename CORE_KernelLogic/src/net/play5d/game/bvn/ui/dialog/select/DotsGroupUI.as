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

public class DotsGroupUI extends Sprite {
    include '../../../../../../../../include/_INCLUDE_.as';

    public var onDotClick:Function;
    private var _dotArr:Array;

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

    public function updateByPage(v:int):void {
        for each(var d:DotItemUI in _dotArr) {
            d.focus(d.page == v);
        }
    }

    public function destory():void {
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
