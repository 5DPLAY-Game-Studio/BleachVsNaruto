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
import com.greensock.TweenLite;

public class PPTef_scrollH extends BasePPTEffect {
    public function PPTef_scrollH(direct:int = 1) {
        super();
        this.direct = direct;
    }

    public var direct:int = 1;
    private var _tween:TweenLite;

    protected override function initStart():void {
        _sp.x         = 0;
        _currentPic.x = 0;

        switch (direct) {
        case 1:
            _prevPic.x = -_pointer.size.x;
            _nextPic.x = _pointer.size.x;
            break;
        case -1:
            _prevPic.x = _pointer.size.x;
            _nextPic.x = -_pointer.size.x;
            break;
        }
    }

//		public override function initPrev():void{
//			_prevPic.x = -_pointer.size.x;
//		}
//		public override function initNext():void{
//			_nextPic.x = _pointer.size.x;
//		}
    public override function tweenNext(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {x: -_size.x, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {x: _size.x, onComplete: back});
            break;
        }
    }

    public override function tweenPrev(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {x: _size.x, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {x: -_size.x, onComplete: back});
            break;
        }
    }

    public override function tweenBack():void {
        var t:Number = duration / 2;
        _tween       = TweenLite.to(_sp, t, {x: 0});
    }

    public override function tweening():Boolean {
        return _tween && _tween.active;
    }

    public override function tweenStop():void {
        if (_tween) {
            _tween.kill();
        }
    }


    protected override function onDraging():void {
        _sp.x = mousePoint().x - _downP.x;
    }

    protected override function dragNext():Boolean {
        return _sp.x - _downSPP.x < -100;
    }

    protected override function dragPrev():Boolean {
        return _sp.x - _downSPP.x > 100;
    }
}
}
