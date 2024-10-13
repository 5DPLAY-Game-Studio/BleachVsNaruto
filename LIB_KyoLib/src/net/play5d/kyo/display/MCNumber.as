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
import flash.display.Sprite;

public class MCNumber extends Sprite {
    /**
     * 以MovieClip作为资源的数字，以跳帧的方式实现
     * @param mc MovieClip的导出类型
     * @param number 赋值数字
     * @param startFrame 数字的起始帧
     * @param mcWidth MovieClip的宽度，-1时，自动取MC的宽度
     *
     */
    public function MCNumber(mc:Class, number:uint, startFrame:int = 1, mcWidth:Number = -1, bits:uint = 0) {
        _mc             = mc;
        _bits           = bits;
        this.startFrame = startFrame;
        this.mcWidth    = mcWidth;
        this.number     = number;
    }
    public var mcWidth:Number = -1;
    public var startFrame:int;
    protected var _mc:Class;
    protected var _mcs:Array = [];
    protected var _bits:uint;

    protected var _number:uint;

    public function get number():uint {
        return _number;
    }

    public function set number(v:uint):void {
        _number = v;
        for each(var m:DisplayObject in _mcs) {
            removeChild(m);
        }
        _mcs              = [];
        var numStr:String = v.toString();

        while (numStr.length < _bits) {
            numStr = '0' + numStr;
        }

        var xx:Number = 0;
        for (var i:int; i < numStr.length; i++) {
            var w:String          = numStr.charAt(i);
            var wmc:DisplayObject = createNum(int(w));
            wmc.x                 = xx;
            xx += mcWidth == -1 ? wmc.width : mcWidth;
        }
    }

    protected function createNum(i:int):DisplayObject {
        var mc:MovieClip = new _mc();
        mc.gotoAndStop(startFrame + i);
        addChild(mc);
        _mcs.push(mc);
        return mc;
    }
}
}
