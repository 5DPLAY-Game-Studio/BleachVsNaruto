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
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoUtils;

public class IphoneScrollPane extends Sprite {
    public function IphoneScrollPane(size:Point) {
        _size = size;
    }

    public var dragPixel:int    = 5;
    public var H_enab:Boolean   = true;
    public var V_enab:Boolean   = true;
    public var enabled:Boolean  = true;
    private var _size:Point;
    private var _downPoint:Point;
    private var _release:Boolean;
    private var _mouseSpd:Point = new Point();
    private var _downSR:Rectangle;
    private var _draging:Boolean;

    private var _source:DisplayObject;

    public function get source():DisplayObject {
        return _source;
    }

    public function set source(value:DisplayObject):void {
        _source = value;
        addChild(_source);
        updateScrollRect();
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);


        graphics.clear();
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, _source.width, _source.height);
        graphics.endFill();
    }

    public function get scrollH():Number {
        return -scrollRect.x;
    }

    public function set scrollH(v:Number):void {
        scrollRect = new Rectangle(-v, scrollRect.y, _size.x, _size.y);
    }

    public function get scrollV():Number {
        return -scrollRect.y;
    }

    public function set scrollV(v:Number):void {
        scrollRect = new Rectangle(scrollRect.x, -v, _size.x, _size.y);
    }

    public function destory():void {
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    public function move(xx:Number, yy:Number = 0):void {
        var w:Number       = _size.x;
        var h:Number       = _size.y;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        if (_release) {
            rect = scrollRect.clone();
        }

        if (_release) {
            rect.x += _mouseSpd.x;
            rect.y += _mouseSpd.y;
        }
        else {
            rect.x      = xx;
            _mouseSpd.x = xx;

            rect.y      = yy;
            _mouseSpd.y = yy;
        }

        if (_downSR) {
            rect.x += _downSR.x;
            rect.y += _downSR.y;
        }
        if (_release) {
            _mouseSpd.x = KyoUtils.num_wake(_mouseSpd.x, 3);
            if (_mouseSpd.x > 6 && rect.x > (
                    _source.width - _size.x
            ) + 100) {
                _mouseSpd.x = -6;
            }
            if (_mouseSpd.x < -6 && rect.x < -100) {
                _mouseSpd.x = 6;
            }

            _mouseSpd.y = KyoUtils.num_wake(_mouseSpd.y, 3);
            if (_mouseSpd.y > 6 && rect.y > (
                    _source.height - _size.y
            ) + 100) {
                _mouseSpd.y = -6;
            }
            if (_mouseSpd.y < -6 && rect.y < -100) {
                _mouseSpd.y = 6;
            }

            if (Math.abs(_mouseSpd.x) < 1 && Math.abs(_mouseSpd.y) < 1) {
                finalEndDrag();
            }
        }
        updateScrollRect(rect);
    }

    protected function checkDraging(xx:Number, yy:Number):void {
        if (H_enab) {
            _draging ||= Math.abs(xx) > dragPixel;
        }
        if (V_enab) {
            _draging ||= Math.abs(yy) > dragPixel;
        }

        if (_draging) {
            if (stage) {
                stage.mouseChildren = false;
            }
        }
    }

    private function finalEndDrag():void {
        removeEventListener(Event.ENTER_FRAME, draging);
        var rect:Rectangle = scrollRect.clone();
        var to:Object      = {};

        if (_source.width < _size.x) {
            to['x'] = 0;
        }
        else {
            if (rect.x < 0) {
                to['x'] = 0;
            }
            if (_size) {
                if (rect.x > _source.width - _size.x) {
                    to['x'] = _source.width - _size.x;
                }
            }
        }

        if (_source.height < _size.y) {
            to['y'] = 0;
        }
        else {
            if (rect.y < 0) {
                to['y'] = 0;
            }
            if (_size) {
                if (rect.y > _source.height - _size.y) {
                    to['y'] = _source.height - _size.y;
                }
            }
        }

        if (to['x'] != undefined || to['y'] != undefined) {
            to['onUpdate'] = function ():void {
                updateScrollRect(rect);
            };
            TweenLite.killTweensOf(rect);
            TweenLite.to(rect, 0.5, to);
            //trace('TweenLite',to['x'],to['y']);
        }

        removeListener();
    }

    private function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
            stage.mouseChildren = true;
        }
    }

    private function mousePoint():Point {
        if (!stage) {
            return null;
        }
        var xx:Number = _downPoint.x - stage.mouseX;
        var yy:Number = _downPoint.y - stage.mouseY;
        if (!H_enab) {
            xx = 0;
        }
        if (!V_enab) {
            yy = 0;
        }
        return new Point(xx, yy);
    }

    private function updateScrollRect(rect:Rectangle = null):void {
        if (rect) {
            scrollRect = rect;
        }
        else {
            scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        }
    }

    private function beginDrag(e:MouseEvent):void {
        if (!enabled) {
            return;
        }
        if (!_size) {
            return;
        }

        _downPoint = new Point(stage.mouseX, stage.mouseY);
        _downSR    = scrollRect;

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        _release = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    private function endDrag(e:MouseEvent):void {
        _release = true;
        _downSR  = null;

        var mux:Point = mousePoint();
        if (!mux) {
            return;
        }

        _mouseSpd.x = mux.x - _mouseSpd.x;
        _mouseSpd.y = mux.y - _mouseSpd.y;

        if (Math.abs(_mouseSpd.x) < 5 && Math.abs(_mouseSpd.y) < 5) {
            finalEndDrag();
        }
    }

    private function draging(e:Event):void {
        var pp:Point = mousePoint();
        if (!pp) {
            return;
        }
        checkDraging(pp.x, pp.y);
        if (_draging) {
            move(pp.x, pp.y);
        }
    }

}
}
