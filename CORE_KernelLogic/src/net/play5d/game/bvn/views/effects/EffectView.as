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

package net.play5d.game.bvn.views.effects {
import flash.display.Bitmap;
import flash.geom.Point;

import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.BitmapDataCacheVO;
import net.play5d.game.bvn.data.EffectVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.kyo.utils.KyoMath;

public class EffectView {
    include '../../../../../../../include/_INCLUDE_.as';

    public function EffectView(data:EffectVO) {
        _data             = data;
        display           = new Bitmap();
        display.blendMode = data.blendMode;
        display.smoothing = EffectCtrl.EFFECT_SMOOTHING;
        _bitmapDatas      = data.bitmapDataCache;
        _frameLabels      = data.frameLabelCache;
    }
    public var display:Bitmap;
    public var autoRemove:Boolean = true;
    public var loopPlay:Boolean   = false;
    public var holdFrame:int = -1;
    public var isActive:Boolean = true;
    protected var _target:IGameSprite;
    protected var _data:EffectVO;
    private var _onRemoveFuncs:Array;
    private var _isDestoryed:Boolean;
    private var _bitmapDatas:Vector.<BitmapDataCacheVO>;
    private var _frameLabels:Object;
    private var _orgX:Number = 0;
    private var _orgY:Number = 0;
    private var _curFrame:int;
    private var _rotation:int;
    private var _direct:int;

    /**
     * 抽象方法，设置关联对象
     */
    public function setTarget(v:IGameSprite):void {
        _target = v;
    }

    public function setPos(x:Number, y:Number):void {
        _orgX = x;
        _orgY = y;
    }

    public function start(x:Number = 0, y:Number = 0, direct:int = 1, playSound:Boolean = true):void {

        _orgX = x;
        _orgY = y;

        _direct = _rotation != 0 ? 1 : direct;

        display.scaleX = _direct;


        _curFrame = 0;

        if (_data.randRotate) {
            randRotate();
        }
        if (playSound && _data.sound) {
            SoundCtrl.I.playEffectSound(_data.sound);
        }

        renderDisplay();
        isActive = true;

    }

    public function destory():void {
        _isDestoryed = true;
        if (isActive) {
            removeSelf();
        }
        display = null;
    }

    public function gotoAndPlay(frame:Object):void {
        if (frame is int) {
            _curFrame = int(frame);
        }
        if (frame is String) {
            for (var i:String in _frameLabels) {
                if (_frameLabels[i] == frame) {
                    _curFrame = int(i);
                }
            }
        }
    }

    public function render():void {

    }

    public function renderAnimate():void {

        if (_isDestoryed) {
            return;
        }

        var removed:Boolean = false;

        if (loopPlay) {
            if (_curFrame == _bitmapDatas.length - 1) {
                _curFrame = 0;
            }
        }
        else {
            if (autoRemove) {
                if (_curFrame == _bitmapDatas.length - 1) {
                    if (holdFrame == -1) {
                        removeSelf();
                        removed = true;
                    }
                    else {
                        _curFrame = 0;
                    }
                }

                if (holdFrame != -1) {
                    if (holdFrame-- <= 0) {
                        removeSelf();
                        removed = true;
                    }
                }
            }
        }

        if (!removed) {
            renderFrameLabel();
            renderDisplay();
            _curFrame++;
        }
    }

    public function remove():void {
        removeSelf();
    }

    public function addRemoveBack(func:Function):void {
        _onRemoveFuncs ||= [];
        if (_onRemoveFuncs.indexOf(func) != -1) {
            return;
        }
        _onRemoveFuncs.push(func);
    }

    private function randRotate():void {
        _rotation        = Math.random() * 360;
        display.rotation = _rotation;
        display.scaleX   = 1;
    }

    private function renderDisplay():void {
        var frameVO:BitmapDataCacheVO = _bitmapDatas[_curFrame];
        if (frameVO == null) {
            display.bitmapData = null;
        }
        else {
            display.bitmapData = frameVO.bitmapData;

            if (_rotation != 0) {
                var radians:Number = KyoMath.asRadians(_rotation);
                var dis:Point      = KyoMath.getPointByRadians(new Point(frameVO.offsetX, frameVO.offsetY), radians);
                display.x          = _orgX + dis.x;
                display.y          = _orgY + dis.y;
            }
            else {
                display.x = _orgX + frameVO.offsetX * _direct;
                display.y = _orgY + frameVO.offsetY;
            }

        }

    }

    private function renderFrameLabel():void {
        var frameLabel:String = _frameLabels[_curFrame];
        switch (frameLabel) {
        case 'loop':
            gotoAndPlay(1);
            break;
        }
    }

    private function removeSelf():void {

        isActive = false;

        for each(var i:Function in _onRemoveFuncs) {
            i(this);
        }
        _onRemoveFuncs = null;

        if (display && display.parent) {
            display.parent.removeChild(display);
        }
    }

}
}
