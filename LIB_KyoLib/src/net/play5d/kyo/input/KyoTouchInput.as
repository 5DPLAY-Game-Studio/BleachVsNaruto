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

package net.play5d.kyo.input {
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class KyoTouchInput extends EventDispatcher {
    public function KyoTouchInput(stage:Stage) {
        _stage = stage;

        enbaled = true;
    }

    public var slidePos:int = 20;
    public var enableArea:Rectangle;
    private var _stage:Stage;
    private var _downPoint:Point;

    public function set enbaled(v:Boolean):void {
        _stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
        _stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);

        _stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
        _stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
    }

    private function checkarea(sx:Number, sy:Number):Boolean {
        if (enableArea) {
            if (sx > enableArea.width || sx < enableArea.x) {
                return false;
            }
            if (sy > enableArea.height || sy < enableArea.y) {
                return false;
            }
        }
        return true;
    }

    private function doSlide():void {
        if (!_downPoint) {
            return;
        }
        if (!checkarea(_stage.mouseX, _stage.mouseY)) {
            return;
        }
        var x:Number = _stage.mouseX - _downPoint.x;
        var y:Number = _stage.mouseY - _downPoint.y;
        if (Math.abs(x) >= Math.abs(y)) {
            //横向滑动
            if (x > slidePos) {
                dispatchEvent(
                        new KyoTouchEvent(KyoTouchEvent.SLIDE, {direct: KyoTouchEvent.DIRECT_RIGHT}));
            }
            if (x < -slidePos) {
                dispatchEvent(
                        new KyoTouchEvent(KyoTouchEvent.SLIDE, {direct: KyoTouchEvent.DIRECT_LEFT}));
            }
        }
        else {
            //竖向滑动
            if (y > slidePos) {
                dispatchEvent(
                        new KyoTouchEvent(KyoTouchEvent.SLIDE, {direct: KyoTouchEvent.DIRECT_DOWN}));
            }
            if (y < -slidePos) {
                dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direct: KyoTouchEvent.DIRECT_UP}));
            }
        }
    }

    private function mouseHandler(e:MouseEvent):void {
        switch (e.type) {
        case MouseEvent.MOUSE_DOWN:
            var sx:Number = _stage.mouseX;
            var sy:Number = _stage.mouseY;
            if (!checkarea(sx, sy)) {
                return;
            }
            _downPoint = new Point(sx, sy);
            break;
        case MouseEvent.MOUSE_UP:
            doSlide();
            _downPoint = null;
            break;
        }
    }
}
}
