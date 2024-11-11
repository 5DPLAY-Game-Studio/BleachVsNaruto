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

package net.play5d.kyo.display.ui.ppt.effect {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import net.play5d.kyo.display.ui.ppt.PicPointer;

public class BasePPTEffect {
    public function BasePPTEffect() {
    }

    public var drag:Boolean;
    public var draging:Boolean;
    public var duration:Number = 1;//动画播放间隔时间
    protected var _pointer:PicPointer;
    protected var _size:Point;
    protected var _sp:Sprite;
    protected var _currentPic:DisplayObject;
    protected var _prevPic:DisplayObject;
    protected var _nextPic:DisplayObject;
    protected var _downP:Point;
    protected var _downSPP:Point;

    public final function initlize(v:PicPointer, sp:Sprite):void {
        _pointer = v;
        _size    = _pointer.size.clone();
        _sp      = sp;
    }

    public final function canClick():Boolean {
        if (_downP) {
            var jl:Number = Math.abs(_pointer.mouseX - _downP.x) + Math.abs(_pointer.mouseY - _downP.y);
            return jl < 20;
        }
        return true;
    }

    public function destory():void {
        if (_sp) {
            _sp.removeEventListener(MouseEvent.MOUSE_DOWN, dragDown);
            _sp = null;
        }
        if (_pointer) {
            _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
            if (_pointer.stage) {
                _pointer.stage.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
            }
            _pointer.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
            _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
        }
    }

    public function setPics(cur:DisplayObject, next:DisplayObject, prev:DisplayObject):void {
        _currentPic = cur;
        _nextPic    = next;
        _prevPic    = prev;
        initStart();
    }

    public final function setCurrent(v:DisplayObject):void {
        _currentPic = v;
        initStart();
    }

    public final function setNext(v:DisplayObject):void {
        _nextPic = v;
        initStart();
    }

//		public function initPrev():void{}

    public final function setPrev(v:DisplayObject):void {
        _prevPic = v;
        initStart();
    }

//		public function initNext():void{}
    public function tweenNext(back:Function):void {
    }

    public function tweenPrev(back:Function):void {
    }

    public function tweenBack():void {
    }

    public function tweening():Boolean {
        return false;
    }

    public function tweenStop():void {
    }

    public final function initDrag():void {
        _sp.removeEventListener(MouseEvent.MOUSE_DOWN, dragDown);
        _sp.addEventListener(MouseEvent.MOUSE_DOWN, dragDown);
    }

    protected function initStart():void {
    }

    protected function onDraging():void {
    }

    protected function dragNext():Boolean {
        return false;
    }

    protected function dragPrev():Boolean {
        return false;
    }

    protected final function mousePoint():Point {
        return new Point(_pointer.mouseX, _pointer.mouseY);
    }

    private final function dragDown(e:MouseEvent):void {
        _downP   = new Point(_pointer.mouseX - _sp.x, _pointer.mouseY - _sp.y);
        _downSPP = new Point(_sp.x, _sp.y);

        if (tweening()) {
            return;
        }

        if (_pointer.stage) {
            _pointer.stage.addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }
        else {
            _pointer.addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }

        _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
        _pointer.addEventListener(Event.ENTER_FRAME, drag_enterframe);

        _pointer.pause();
    }

    private function drag_enterframe(e:Event):void {
        draging ||= Math.abs(_pointer.mouseX - _downP.x) > 10 || Math.abs(_pointer.mouseY - _downP.y) > 10;
        if (draging) {
            onDraging();
        }
    }

//		private var _prev:Boolean;
    private function dragUp(e:MouseEvent):void {
        if (_pointer.stage) {
            _pointer.stage.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
        }

        _pointer.removeEventListener(MouseEvent.MOUSE_UP, dragUp);

        _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);

        if (!draging) {
            return;
        }
        draging = false;

        if (dragNext()) {
            _pointer.toNext();
            return;
        }
        if (dragPrev()) {
            _pointer.toPrev();
            return;
        }
        tweenBack();
    }


}
}
