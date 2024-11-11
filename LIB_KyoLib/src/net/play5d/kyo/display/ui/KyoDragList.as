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

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import net.play5d.kyo.utils.KyoUtils;

public class KyoDragList extends KyoTileList {
    public function KyoDragList(
            dispalys:Array, dragType:int = KyoDragType.DRAG_TYPE_V, hrow:int = int.MAX_VALUE, vrow:int = 1) {
        super(dispalys, hrow, vrow);
        this.dragType = dragType;
        addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
    }

    public var dragType:int;
    public var dragPixel:int     = 5;
    protected var _downPoint:Point;
    protected var _downListPoint:Point;
    protected var _haveToDrag:Boolean;
    protected var _draging:Boolean;
    private var _tween:TweenLite;
    private var _mouseSpd:Number = 0;
    private var _release:Boolean;
    private var _asctimer:Timer;
    private var _tweenDuration:Number;
    private var _perpage:int;
    private var _curid:int;
    private var _downSR:Rectangle;

    public override function update():void {
        super.update();
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
    }

    protected override function updateScrollBar():void {
        if (!scrollBar) {
            return;
        }
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            break;
        case KyoDragType.DRAG_TYPE_H:
            scrollBar.update(scrollRect.x / _width);
            break;
        case KyoDragType.DRAG_TYPE_V:
            scrollBar.update(scrollRect.y / _height);
            break;
        }
    }

    public function destory():void {
        removeEventListener(Event.ENTER_FRAME, draging);
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    public function moveById(id:int, tweenTime:Number = 0):void {
        var xx:Number = (
                                unitySize.x + gap.x
                        ) * id;
        var yy:Number = (
                                unitySize.y + gap.y
                        ) * id;
        if (tweenTime == 0) {
            move(xx, yy);
        }
        else {
            var o:Object = {};
            o.x          = scrollRect.x;
            o.y          = scrollRect.y;
            _tween       = TweenLite.to(o, tweenTime, {
                x: xx, y: yy, onUpdate: function ():void {
                    move(o.x, o.y);
                }
            });
        }
    }

    public function move(xx:Number, yy:Number = 0):void {
        var w:Number       = maskSize ? maskSize.x : _width;
        var h:Number       = maskSize ? maskSize.y : _height;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        if (_release) {
            rect = scrollRect.clone();
        }
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            rect.x = xx;
            rect.y = yy;
            break;
        case KyoDragType.DRAG_TYPE_H:
            if (_release) {
                rect.x += _mouseSpd;
                if (rect.x < 0 || rect.x > (
                        _width - maskSize.x
                )) {
                    _mouseSpd /= 10;
                }
            }
            else {
                rect.x    = xx;
                _mouseSpd = xx;
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (_release) {
                rect.y += _mouseSpd;
                if (rect.y < 0 || rect.y > (
                        _height - maskSize.y
                )) {
                    _mouseSpd /= 10;
                }
            }
            else {
                rect.y    = yy;
                _mouseSpd = yy;
            }
            break;
        }
        if (_release) {
            _mouseSpd = KyoUtils.num_wake(_mouseSpd, 3);
            if (rect.y > _height) {
                _mouseSpd = 0;
            }
            if (rect.y < -w * 0.8) {
                _mouseSpd = 0;
            }
            if (Math.abs(_mouseSpd) < 1) {
                finalEndDrag();
            }
        }
        if (_downSR) {
            rect.x += _downSR.x;
            rect.y += _downSR.y;
        }
        updateScrollRect(rect);
        updateScrollBar();
    }

    /**
     * 自动滚动
     * @param time 间隔时间（毫秒）
     */
    public function autoScroll(time:int, tweenDuration:Number = 1):void {
        _tweenDuration = tweenDuration;
        _perpage       = Math.round(maskSize.y / (
                unitySize.y + gap.y
        ));

        _asctimer = new Timer(time);
        _asctimer.addEventListener(TimerEvent.TIMER, onTimerScroll);
        _asctimer.start();
    }

    protected final function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
            stage.mouseChildren = true;
        }
        removeEventListener(Event.ENTER_FRAME, draging);
    }

    protected function mousePoint():Point {
        var xx:Number = _downPoint.x - stage.mouseX;
        var yy:Number = _downPoint.y - stage.mouseY;
        return new Point(xx, yy);
    }

    protected function checkDraging(xx:Number, yy:Number):void {
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            _draging ||= Math.abs(xx) > dragPixel || Math.abs(yy) > dragPixel;
            break;
        case KyoDragType.DRAG_TYPE_H:
            _draging ||= Math.abs(xx) > dragPixel;
            break;
        case KyoDragType.DRAG_TYPE_V:
            _draging ||= Math.abs(yy) > dragPixel;
            break;
        }
        if (_draging) {
            if (stage) {
                stage.mouseChildren = false;
            }
        }
    }

    private function updateScrollRect(rect:Rectangle = null):void {
        rect ||= scrollRect;
        scrollRect = rect;
    }

    private function finalEndDrag():void {
        var rect:Rectangle = scrollRect.clone();
        var to:Object      = {};

        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            if (rect.x < 0) {
                to['x'] = 0;
            }
            if (maskSize) {
                if (rect.x > _width - maskSize.x) {
                    to['x'] = _width - maskSize.x;
                }
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (rect.y < 0) {
                to['y'] = 0;
            }
            if (maskSize) {
                if (rect.y > _height - maskSize.y) {
                    to['y'] = _height - maskSize.y;
                }
            }
            break;
        }
        if (to['x'] != undefined || to['y'] != undefined) {
            to['onUpdate']   = function ():void {
                updateScrollRect(rect);
            };
            to['onComplete'] = tweenover;
            _tween           = TweenLite.to(rect, 0.5, to);
        }
        else {
            tweenover();
        }
        removeListener();

        function tweenover():void {
            _release = false;
            switch (dragType) {
            case KyoDragType.DRAG_TYPE_H:
                _curid = Math.round(scrollRect.x / unitySize.x);
                break;
            case KyoDragType.DRAG_TYPE_V:
                _curid = Math.round(scrollRect.y / unitySize.y);
                break;
            }
            moveById(_curid, 0.5);
            if (_asctimer) {
                _asctimer.reset();
                _asctimer.start();
            }
        }
    }

    protected function endDrag(e:MouseEvent):void {
        _downSR = null;
        if (!_draging) {
            removeListener();
            if (_asctimer) {
                _asctimer.reset();
                _asctimer.start();
            }
            return;
        }

        _release = true;

        var mux:Point = mousePoint();

        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            _mouseSpd = mux.x - _mouseSpd;
            break;
        case KyoDragType.DRAG_TYPE_V:
            _mouseSpd = mux.y - _mouseSpd;
            break;
        }
        if (Math.abs(_mouseSpd) < 5) {
            finalEndDrag();
        }
    }

    protected function draging(e:Event):void {
        var pp:Point = mousePoint();
        checkDraging(pp.x, pp.y);
        if (_draging) {
            move(pp.x, pp.y);
        }
    }

    private function onTimerScroll(e:TimerEvent):void {
        if (_curid > displays.length - _perpage - 1) {
            _curid = 0;
            moveById(_curid, _tweenDuration);
        }
        else {
            moveById(++_curid, _tweenDuration);
        }
    }

    private function beginDrag(e:MouseEvent):void {
        if (_tween && _tween.active) {
            return;
        }

        if (!_haveToDrag) {
            if (!maskSize) {
                return;
            }
            switch (dragType) {
            case KyoDragType.DRAG_TYPE_H:
                if (_width < maskSize.x) {
                    return;
                }
                break;
            case KyoDragType.DRAG_TYPE_V:
                if (_height < maskSize.y) {
                    return;
                }
                break;
            }
        }

        if (_asctimer) {
            _asctimer.stop();
        }

        _downSR        = scrollRect;
        _downPoint     = new Point(stage.mouseX, stage.mouseY);
        _downListPoint = new Point(this.x, this.y);

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        _release = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }
}
}
