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

package net.play5d.kyo.display {
public class BMCCacher {
    public function BMCCacher(totalAmount:int = -1) {
        _total = totalAmount;
    }

    private var _total:int;
    private var _amount:int;
    private var _cacheObj:Object = {};

    public function cache(id:String, insarray:Array):void {
        _amount++;
        if (_total != -1 && _amount > _total) {
            clean();
        }
        _cacheObj[id] = insarray;
    }

    public function get(id:String):Array {
        return _cacheObj[id];
    }

    public function remove(id:String):void {
        var a:Array = _cacheObj[id];
        for each(var b:BitmapMCFrameVO in a) {
            b.destory();
            b = null;
        }
        a = null;
        delete _cacheObj[id];
    }

    public function clean():void {
        for each(var i:Array in _cacheObj) {
            for each(var j:* in i) {
                if (j is BitmapMCFrameVO) {
                    var b:BitmapMCFrameVO = j;
                    b.destory();
                }
                j = null;
            }
            i = null;
        }
        _cacheObj = {};
        _amount   = 0;
    }

}
}
