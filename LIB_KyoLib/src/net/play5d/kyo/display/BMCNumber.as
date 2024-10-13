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
import flash.display.DisplayObject;
import flash.display.MovieClip;

public class BMCNumber extends MCNumber {
    public function BMCNumber(mc:Object, number:uint, startFrame:int = 1, mcWidth:Number = -1) {
        var mcc:Class;
        if (mc is Class) {
            mcc = mc as Class;
        }
        if (mc is Array) {
            _insArray = mc as Array;
        }
        super(mcc, number, startFrame, mcWidth);
    }
    private var _insArray:Array;

    protected override function createNum(i:int):DisplayObject {
        var bmc:BitmapMovieClip = new BitmapMovieClip(false);
        if (_insArray) {
            bmc.insArray = _insArray;
        }
        else {
            var mc:MovieClip = new _mc();
            bmc.draw(mc);
        }
        bmc.gotoAndStop(startFrame + i);
        addChild(bmc);
        _mcs.push(bmc);
        return bmc;
    }
}
}
