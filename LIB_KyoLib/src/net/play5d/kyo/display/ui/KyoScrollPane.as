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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class KyoScrollPane extends Sprite {
    public function KyoScrollPane(maskSize:Point, source:DisplayObject = null, dragType:int = KyoDragType.DRAG_TYPE_V) {
        this.dragType = dragType;
        this.maskSize = maskSize;
        if (source) {
            this.source = source;
        }

        this.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
    }
    public var dragType:int;
    public var maskSize:Point;
    public var scrollBar:IKyoScrollBar;
    public var dragPixel:int = 5;
    protected var _downPoint:Point;
    protected var _downListPoint:Point;
    protected var _haveToDrag:Boolean;
    protected var _draging:Boolean;
    private var _downSR:Rectangle;
    private var _width:Number;
    private var _height:Number;

    private var _source:DisplayObject;

    public function get source():DisplayObject {
        return _source;
    }

    public function set source(value:DisplayObject):void {
        _source = value;

        _source.x = _source.y = 0;
        addChild(_source);
        update();
    }

    protected function get mousePoint():Point {
        var xx:Number = _downPoint.x - stage.mouseX;
        var yy:Number = _downPoint.y - stage.mouseY;
        return new Point(xx, yy);
    }

    private function get allowDrag():Boolean {
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            if ((
                        _width < maskSize.x
                ) && (
                        _height < maskSize.y
                )) {
                return false;
            }
            break;
        case KyoDragType.DRAG_TYPE_H:
            if (_width < maskSize.x) {
                return false;
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (_height < maskSize.y) {
                return false;
            }
        }
        return true;
    }

    public function destory():void {
        this.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        removeEventListener(Event.ENTER_FRAME, draging);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    public function update():void {
        _width  = _source.width;
        _height = _source.height;

        scrollRect = new Rectangle(0, 0, maskSize.x, maskSize.y);

        graphics.clear();
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();

        updateScrollBar();
    }

    public function move(x:Number, y:Number):void {
        var rect:Rectangle = scrollRect.clone();
        rect.x -= x;
        rect.y -= y;
        checkout(rect);
        scrollRect = rect;
    }

    protected final function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
            stage.mouseChildren = true;
        }
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

    protected function updateScrollBar():void {
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

    private function checkout(rect:Rectangle):void {
        var w:Number = _width - maskSize.x;
        var h:Number = _height - maskSize.y;
        if (rect.x > w) {
            rect.x = w;
        }
        if (rect.y > h) {
            rect.y = h;
        }
        if (rect.x < 0) {
            rect.x = 0;
        }
        if (rect.y < 0) {
            rect.y = 0;
        }
    }

    protected function draging(e:Event):void {
        var pp:Point = mousePoint;
        checkDraging(pp.x, pp.y);
        var w:Number       = maskSize.x;
        var h:Number       = maskSize.y;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            rect.x = pp.x;
            rect.y = pp.y;
            break;
        case KyoDragType.DRAG_TYPE_H:
            rect.x = pp.x;
            break;
        case KyoDragType.DRAG_TYPE_V:
            rect.y = pp.y;
            break;
        }
        if (_draging) {
            if (_downSR) {
                rect.x += _downSR.x;
                rect.y += _downSR.y;
            }
            //				trace(rect);
            checkout(rect);

            scrollRect = rect;
            updateScrollBar();
        }
    }

    protected function endDrag(e:MouseEvent):void {
        removeListener();
        removeEventListener(Event.ENTER_FRAME, draging);
//			setTimeout(function():void{mouseEnabled = mouseChildren = true;},1000);
    }

    private function beginDrag(e:MouseEvent):void {
        if (!allowDrag) {
            return;
        }

        _downSR        = scrollRect;
        _downPoint     = new Point(stage.mouseX, stage.mouseY);
        _downListPoint = new Point(this.x, this.y);

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

}
}
