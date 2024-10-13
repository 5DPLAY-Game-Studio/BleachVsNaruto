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

package net.play5d.kyo.stage.effect {
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.DisplayObject;
import flash.geom.Point;

import net.play5d.kyo.stage.Istage;

public class ZoomEffect implements IStageFadEffect {
    public function ZoomEffect(duration:Number = 0.3, back:Boolean = true) {
        _duration = duration;
        _back     = back;
    }
    private var _duration:Number;
    private var _back:Boolean;
    private var _fixPosition:Boolean;

    public function fadIn(stage:Istage, complete:Function = null):void {
        var z:Number        = 0.5;
        var p:Point         = new Point();
        var d:DisplayObject = stage.display;
        p.x                 = d.x + d.width * z / 2;
        p.y                 = d.y + d.height * z / 2;

        var to:Object = {scaleX: z, scaleY: z, x: p.x, y: p.y, onComplete: complete};
        if (_back) {
            to['ease'] = Back.easeOut;
        }
        TweenLite.from(stage.display, _duration, to);
    }

    public function fadOut(stage:Istage, complete:Function = null):void {
        var z:Number        = 0.1;
        var p:Point         = new Point();
        var d:DisplayObject = stage.display;
        p.x                 = d.x + d.width / 2 - d.width * z;
        p.y                 = d.y + d.height / 2 - d.height * z;
        TweenLite.to(stage.display, _duration, {scaleX: z, scaleY: z, x: p.x, y: p.y, onComplete: complete});
    }
}
}
