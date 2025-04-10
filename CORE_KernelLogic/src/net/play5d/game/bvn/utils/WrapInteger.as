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

package net.play5d.game.bvn.utils {
public class WrapInteger {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _rndArr:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    public function WrapInteger(v:int) {
        _offset = Math.floor(Math.random() * _rndArr.length);
        _w      = v ^ _rndArr[_offset];

    }
    private var _w:int;
    private var _offset:int;

    public function setValue(v:int):void {
        _offset = Math.floor(Math.random() * _rndArr.length);
        _w      = v ^ _rndArr[_offset];
    }

    public function getValue():int {//trace(_w,_offset);
        return _w ^ _rndArr[_offset];
    }

    public function toString():String {
        var tmp:int = _w ^ _rndArr[_offset];
        return tmp.toString();
    }
}
}
