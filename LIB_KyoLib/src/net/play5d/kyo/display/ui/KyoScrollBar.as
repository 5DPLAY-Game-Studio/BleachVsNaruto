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

package net.play5d.kyo.display.ui {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import net.play5d.kyo.utils.KyoUtils;

public class KyoScrollBar extends EventDispatcher implements IKyoScrollBar {
    public static const TYPE_H:int = 0;
    public static const TYPE_V:int = 1;

    public function KyoScrollBar(ui:Sprite, dragRange:Point, type:int = TYPE_V) {
        this.ui         = ui;
        this._dragRange = dragRange;
        this._type      = type;
        _distance       = _dragRange.y - _dragRange.x;

        ui.mouseChildren = false;
        ui.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);
    }

    public var ui:Sprite;
    private var _dragRange:Point;
    private var _type:int;
    private var _distance:Number;
    private var _draging:Boolean;

    public function set enabled(v:Boolean):void {
        ui.mouseEnabled = v;
        if (!v) {
            endDrag();
        }
    }

    public function update(pos:Number):void {
        var pp:Number = pos * _distance;
        if (_type == TYPE_H) {
            ui.x = _dragRange.x + pp;
        }
        if (_type == TYPE_V) {
            ui.y = _dragRange.x + pp;
        }
    }

    private function startDrag(e:MouseEvent):void {
        if (_draging) {
            return;
        }
        _draging = true;

        ui.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);

        ui.addEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    private function onEnterframe(e:Event):void {
        var pp:Number;
        var pos:Point = new Point();
        if (_type == TYPE_H) {
            pp    = KyoUtils.num_fixRange(ui.parent.mouseX, _dragRange);
            ui.x  = pp;
            pos.x = (
                            pp - _dragRange.x
                    ) / _distance;
        }
        if (_type == TYPE_V) {
            pp    = KyoUtils.num_fixRange(ui.parent.mouseY, _dragRange);
            ui.y  = pp;
            pos.y = (
                            pp - _dragRange.x
                    ) / _distance;
        }
        dispatchEvent(new KyoUIEvent(KyoUIEvent.UPDATE, pos));
    }

    private function endDrag(e:MouseEvent = null):void {
        _draging = false;
        ui.removeEventListener(Event.ENTER_FRAME, onEnterframe);
        if (ui.stage) {
            ui.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }
}
}
