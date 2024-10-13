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

package net.play5d.kyo.utils {
public class ArrayLite {
    public function ArrayLite() {
        super();
        _o = {};
    }
    public var length:int;
    private var _o:Object;

    public function push(id:Object, value:*):void {
        if (!_o[id]) {
            length++;
        }
        _o[id] = value;
    }

    public function getItem(id:Object):* {
        return _o[id];
    }

    public function remove(id:Object):void {
        if (!_o[id]) {
            return;
        }

        delete _o[id];
        length--;
        if (length < 0) {
            length = 0;
        }
    }
}
}
