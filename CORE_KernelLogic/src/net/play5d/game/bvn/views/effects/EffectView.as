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
import net.play5d.game.bvn.ctrler.effect.BitmapDataCacheVO;
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.kyo.utils.KyoMath;

/**
 * 按帧缓存画的特效。开始时先画第 0 帧。
 *
 * <p>循环时，下标已经是最后一帧就先改回 0 再画，最后一帧不会出现。不循环且自动移除时，走到最后一帧下标就移除，这一帧也不再画。只有一帧时，开始时画过一次，下一次动画就移除。<code>holdFrame</code> 不是 -1 时，每次动画都先减一，减之前已经小于等于 0 就移除；走到最后一帧时另外把下标改回 0。</p>
 *
 * <p>帧标签 <code>loop</code> 把下标写成 1，本帧画的是第二张，画完再加一。随机旋转会把缩放改成 1，之后再开始时方向也被改成 1。</p>
 */
public class EffectView {

    /**
     * 记下数据和帧缓存，并建一张空位图。数据为 null 时抛错。
     *
     * @param data 特效数据。
     * @throws TypeError 数据为 null 时。
     */
    public function EffectView(data:EffectVO) {
        _data             = data;
        display           = new Bitmap();
        display.blendMode = data.blendMode;
        display.smoothing = EffectCtrl.EFFECT_SMOOTHING;
        _bitmapDatas      = data.bitmapDataCache;
        _frameLabels      = data.frameLabelCache;
    }
    /**
     * 用来画的位图。销毁后是 null。
     */
    public var display:Bitmap;
    /**
     * 播到末尾是否移除。循环打开时这项不生效。
     *
     * @default true
     */
    public var autoRemove:Boolean = true;
    /**
     * 是否循环。打开后最后一帧下标会被改回 0。
     *
     * @default false
     */
    public var loopPlay:Boolean   = false;
    /**
     * 额外停留的动画次数。-1 表示不停留。0 会在下一次动画时移除。
     *
     * @default -1
     */
    public var holdFrame:int      = -1;
    /**
     * 是否还在播放。移除后变成 false，<code>start</code> 会再写成 true。
     *
     * @default true
     */
    public var isActive:Boolean   = true;
    /**
     * 跟随的对象。<code>setTarget</code> 之前是 null。
     */
    protected var _target:IGameSprite;
    /**
     * 构造时传入的特效数据。
     */
    protected var _data:EffectVO;
    private var _onRemoveFuncs:Array;
    private var _isDestroyed:Boolean;
    private var _bitmapDatas:Vector.<BitmapDataCacheVO>;
    private var _frameLabels:Object;
    private var _orgX:Number      = 0;
    private var _orgY:Number      = 0;
    private var _curFrame:int;
    private var _rotation:int;
    private var _direct:int;
    private var _offsetSrc:Point  = new Point();
    private var _offsetRot:Point  = new Point();

    /**
     * 记下关联对象。
     *
     * @param v 关联对象。可以是 null。
     * @example
     * <listing version="3.0">
     * view.setTarget(sprite);
     * </listing>
     */
    public function setTarget(v:IGameSprite):void {
        _target = v;
    }

    /**
     * 记下原点。要等下一次画帧才写到位图上。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * view.setPos(x, y);
     * </listing>
     */
    public function setPos(x:Number, y:Number):void {
        _orgX = x;
        _orgY = y;
    }

    /**
     * 从第 0 帧开始，并立刻画一帧。有自定义声音类时只用它，否则用数据里的声音名。<code>playSound</code> 为 false 时不播。
     *
     * @param x 原点横坐标。默认 0。
     * @param y 原点纵坐标。默认 0。
     * @param direct 方向，写入横向缩放。默认 1。已经随机旋转过时改成 1。
     * @param playSound 是否播声音。默认 true。
     * @throws TypeError 数据缺失时。
     * @example
     * <listing version="3.0">
     * view.start(x, y, 1);
     * </listing>
     */
    public function start(x:Number = 0, y:Number = 0, direct:int = 1, playSound:Boolean = true):void {

        _orgX = x;
        _orgY = y;

        _direct = _rotation != 0 ? 1 : direct;

        display.scaleX = _direct;


        _curFrame = 0;

        if (_data.randRotate) {
            randRotate();
        }

        if (playSound) {
            if (_data.customSndCls) {
                SoundCtrl.I.playSwcSound(_data.customSndCls);
            }
            else if (_data.sound) {
                SoundCtrl.I.playEffectSound(_data.sound);
            }
        }

        renderDisplay();
        isActive = true;

    }

    /**
     * 停掉并清空位图引用。还在播放时会先通知移除回调，并从父级拿下。不释放像素。
     *
     * @example
     * <listing version="3.0">
     * view.destroy();
     * </listing>
     */
    public function destroy():void {
        _isDestroyed = true;
        if (isActive) {
            removeSelf();
        }
        display = null;
    }

    /**
     * 跳到某一帧。整数直接当成缓存下标，1 是第二张。字符串按标签查找，找不到就保持原下标。其它类型什么都不做。
     *
     * @param frame 下标或标签。
     * @throws TypeError 传入字符串但标签表缺失时。
     * @example
     * <listing version="3.0">
     * view.gotoAndPlay('finish');
     * </listing>
     */
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

    /**
     * 空实现。位置跟随由子类写。
     *
     * @example
     * <listing version="3.0">
     * view.render();
     * </listing>
     */
    public function render():void {

    }

    /**
     * 推进一帧动画。已经销毁时直接返回。缓存缺失时抛错。
     *
     * @throws TypeError 帧缓存缺失时。
     * @example
     * <listing version="3.0">
     * view.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {

        if (_isDestroyed) {
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

    /**
     * 立刻移除。会通知回调，并把 <code>isActive</code> 写成 false。
     *
     * @example
     * <listing version="3.0">
     * view.remove();
     * </listing>
     */
    public function remove():void {
        removeSelf();
    }

    /**
     * 登记移除回调。同一个函数只留一份。回调为 null 时也会登记，移除时再调用会抛错。
     *
     * @param func 回调，参数是这个特效。
     * @example
     * <listing version="3.0">
     * view.addRemoveBack(onGone);
     * </listing>
     */
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
                _offsetSrc.x       = frameVO.offsetX;
                _offsetSrc.y       = frameVO.offsetY;
                var dis:Point      = KyoMath.getPointByRadians(_offsetSrc, radians, 1, _offsetRot);
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
