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

import net.play5d.kyo.stage.Istage;

public class StageFadEffectOrg implements IStageFadEffect {
    public function StageFadEffectOrg(time:Number = 0.5, x:Boolean = false, y:Boolean = false,
                                      alpha:Boolean = false, easefun:Function = null
    ) {
        _time        = time;
        _obj         = {};
        _obj.x       = x;
        _obj.y       = y;
        _obj.alpha   = alpha;
        _obj.easefun = easefun;
    }
    private var _obj:Object;
    private var _time:Number;

    public function fadIn(stage:Istage, complete:Function = null):void {
        var to:Object = {};
        if (_obj.x) {
            to.x            = stage.display.x;
            stage.display.x = 0;
        }
        if (_obj.y) {
            to.y            = stage.display.y;
            stage.display.y = 0;
        }
        if (_obj.alpha) {
            to.alpha            = stage.display.alpha;
            stage.display.alpha = 0;
        }
        if (_obj.easefun) {
            to.ease = _obj.easefun;
        }
        if (complete != null) {
            to.onComplete = complete;
        }
        TweenLite.to(stage.display, _time, to);
    }

    public function fadOut(stage:Istage, complete:Function = null):void {
    }
}
}
