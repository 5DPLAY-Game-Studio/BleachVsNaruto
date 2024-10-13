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
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 在一定范围内滚动
 */
public class KyoScroller {
    public function KyoScroller(d:DisplayObject, size:Point, dsize:Point = null) {
        _d     = d;
        _size  = size;
        _dsize = dsize;
        _dsize ||= new Point(_d.width, _d.height);

        updateSC();
    }
    public var speed:Number = 2;
    private var _d:DisplayObject;
    private var _size:Point;
    private var _dsize:Point;
    private var _p:Point    = new Point();
    /**
     * 开始运作
     * @param direct 1:从右向左，2：从左向右，3：从上向下，4：从下向上
     */
    private var _direct:int;

    public function start(direct:int = 1):void {
        _direct = direct;
        stop();
        _d.addEventListener(Event.ENTER_FRAME, moving);
    }

    public function stop():void {
        _d.removeEventListener(Event.ENTER_FRAME, moving);
    }

    private function updateSC():void {
        _d.scrollRect = new Rectangle(_p.x, _p.y, _size.x, _size.y);
    }

    private function moving(e:Event):void {
        switch (_direct) {
        case 1:
            _p.x += speed;
            if (_p.x > _dsize.x) {
                _p.x = -_size.x;
            }
            break;
        case 2:
            _p.x -= speed;
            if (_p.x < -_size.x) {
                _p.x = _size.x;
            }
            break;
        case 3:
            _p.y += speed;
            if (_p.y > _dsize.y) {
                _p.y = -_d.height;
            }
            break;
        case 4:
            _p.y -= speed;
            if (_p.y < -_d.height) {
                _p.y = _d.height;
            }
            break;
        }
        updateSC();
    }
}
}
