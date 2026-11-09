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
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.TouchEvent;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import net.play5d.game.bvn.GameConfig;
import net.play5d.kyo.utils.ArrayMap;
import net.play5d.kyo.utils.KyoDisplayUtils;

/**
 * 舞台上的单指和双指拖动。单例用 <code>I</code>。拖动阈值是 0.1 厘米，要先 <code>init</code>。
 *
 * <p>单指超过阈值的那一帧只把拖动标成 true，不发送移动。发给回调的位移已经除以画面缩放，缩放是 0 时变成 Infinity。抬起后大约 300 毫秒内仍算正在拖，新的按下会被丢掉。还没 <code>init</code> 就按下时，触点已经记下，接着对空舞台抛错，之后的按下也会被丢掉。</p>
 *
 * <p>双指在第二指按下时发送开始。舞台上的移动和抬起用触点对象去查以显示对象为键的表，查不到就拆掉监听并换成空表，移动和结束到不了。点数已经是 2 时再按下仍会加进去，变成 3 以后舞台事件直接返回。</p>
 */
public class TouchUtils {

    private static var _i:TouchUtils;

    /**
     * 唯一实例。第一次取时创建。
     *
     * @return 触摸工具。
     * @example
     * <listing version="3.0">
     * var touch:TouchUtils = TouchUtils.I;
     * </listing>
     */
    public static function get I():TouchUtils {
        _i ||= new TouchUtils();
        return _i;
    }

    private var _oneFingerPoint:TouchPoint;
    private var _oneFingerDragging:Boolean;
    private var _callBackMap:Dictionary    = new Dictionary();
    private var _stage:Stage;
    private var _checkDragDis:Number       = 0;
    private var _callTwoBackMap:Dictionary = new Dictionary();
    private var _twoFingerMap:ArrayMap     = new ArrayMap();
    private var _twoFingerDragging:Boolean;
    private var _twoFingerDelta:Number     = 0;

    /**
     * 记下舞台，并把拖动阈值设成 0.1 厘米。再调用会换舞台，旧舞台上的监听不摘。舞台为 null 时先存下来，第一次按下才抛错。
     *
     * @param stage 舞台。
     * @example
     * <listing version="3.0">
     * TouchUtils.I.init(stage);
     * </listing>
     */
    public function init(stage:Stage):void {
        _stage        = stage;
        _checkDragDis = KyoDisplayUtils.cm2pixel(0.1);
    }

    /**
     * 是否正在拖。单指抬起后大约 300 毫秒内仍为 true。
     *
     * @return 单指或双指标记有一个为 true 时为 true。
     * @example
     * <listing version="3.0">
     * var dragging:Boolean = TouchUtils.I.isDragging();
     * </listing>
     */
    public function isDragging():Boolean {
        return _oneFingerDragging || _twoFingerDragging;
    }

    // 单点触摸
    // =======================================================================================================================

    /**
     * 听这个显示对象上的单指。同一个对象再登记会换成新回调，按下监听只有一份。显示对象为 null 时抛错。
     *
     * @param d 显示对象。
     * @param back 回调，参数是 <code>TouchMoveEvent</code>。为 null 时按下和移动都不调用。
     * @param dragX 是否把横向算进拖动距离。默认 true。
     * @param dragY 是否把纵向算进拖动距离。默认 true。两个都是 false 时，纵向位移不是 0 仍会计入。
     * @throws TypeError 显示对象为 null 时。
     * @example
     * <listing version="3.0">
     * TouchUtils.I.listenOneFinger(view, onDrag);
     * </listing>
     */
    public function listenOneFinger(d:DisplayObject, back:Function, dragX:Boolean = true, dragY:Boolean = true):void {
        _callBackMap[d] = new TouchCallBack(back, dragX, dragY);

        d.removeEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
        d.addEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
    }

    /**
     * 取消单指。显示对象为 null 时抛错。手指还按着时，下一次舞台事件会清掉触点，且不发送抬起。
     *
     * @param d 显示对象。
     * @throws TypeError 显示对象为 null 时。
     * @example
     * <listing version="3.0">
     * TouchUtils.I.unlistenOneFinger(view);
     * </listing>
     */
    public function unlistenOneFinger(d:DisplayObject):void {
        delete _callBackMap[d];
        d.removeEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
    }

    /**
     * 听这个显示对象上的双指。同一个对象再登记会换成新回调。显示对象为 null 时抛错。
     *
     * @param d 显示对象。
     * @param back 回调，参数是 <code>TouchMoveEvent</code>。
     * @throws TypeError 显示对象为 null 时。
     * @example
     * <listing version="3.0">
     * TouchUtils.I.listenTwoFinger(view, onPinch);
     * </listing>
     */
    public function listenTwoFinger(d:DisplayObject, back:Function):void {
        _callTwoBackMap[d] = new TouchTwoCallBack(back);

        d.removeEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
        d.addEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
    }

    /**
     * 取消双指按下监听。已经按住的两点还留在表里。显示对象为 null 时抛错。
     *
     * @param d 显示对象。
     * @throws TypeError 显示对象为 null 时。
     * @example
     * <listing version="3.0">
     * TouchUtils.I.unlistenTwoFinger(view);
     * </listing>
     */
    public function unlistenTwoFinger(d:DisplayObject):void {
        delete _callTwoBackMap[d];
        d.removeEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
    }


    // 两点触摸
    // =======================================================================================================================

    private function oneFingerHandler(e:TouchEvent):void {
        if (_oneFingerPoint) {
            return;
        }

        var d:DisplayObject = e.currentTarget as DisplayObject;

        if (_callBackMap[d]) {
            (
                    _callBackMap[d] as TouchCallBack
            ).callBegin(e.stageX, e.stageY);
        }

        _oneFingerPoint = new TouchPoint(e.touchPointID);

        _oneFingerPoint.stageX = e.stageX;
        _oneFingerPoint.stageY = e.stageY;

        _oneFingerPoint.target = d;

        _oneFingerDragging = false;

        _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
        _stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

        _stage.addEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
        _stage.addEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

    }

    private function stageOneFingerHandler(e:TouchEvent):void {
        if (e.touchPointID != _oneFingerPoint.touchId) {
            return;
        }

        if (!_oneFingerPoint.target || !_callBackMap[_oneFingerPoint.target]) {
            _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
            _stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

            _oneFingerPoint    = null;
            _oneFingerDragging = false;
            return;
        }

        var tc:TouchCallBack = _callBackMap[_oneFingerPoint.target];

        if (e.type == TouchEvent.TOUCH_END) {
            _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
            _stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

            tc.callEnd(e.stageX, e.stageY);

            setTimeout(function ():void {
                _oneFingerPoint   = null;
                _oneFingerDragging = false;
            }, 300);

            return;
        }

        var deltaX:Number = e.stageX - _oneFingerPoint.stageX;
        var deltaY:Number = e.stageY - _oneFingerPoint.stageY;

        if (!_oneFingerDragging) {
            _oneFingerDragging = tc.getDragDistance(deltaX, deltaY) > _checkDragDis;
            return;
        }

        _oneFingerPoint.stageX = e.stageX;
        _oneFingerPoint.stageY = e.stageY;

        tc.callMoving(deltaX / GameConfig.GAME_SCALE.x, deltaY / GameConfig.GAME_SCALE.y);

    }

    private function twoFingerHandler(e:TouchEvent):void {
        if (_twoFingerMap.length > 2) {
            return;
        }

        var d:DisplayObject = e.currentTarget as DisplayObject;
        var tp:TouchPoint   = new TouchPoint(e.touchPointID);

        tp.stageX = e.stageX;
        tp.stageY = e.stageY;
        tp.target = d;

        _twoFingerMap.push(tp.touchId, tp);

        if (_twoFingerMap.length == 2) {
            _twoFingerDragging = false;
            _twoFingerDelta    = 0;

            _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
            _stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

            _stage.addEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
            _stage.addEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

            if (_callTwoBackMap[d]) {
                (
                        _callTwoBackMap[d] as TouchTwoCallBack
                ).callBegin();
            }
        }

    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private function stageTwoFingerHandler(e:TouchEvent):void {
        if (_twoFingerMap.length != 2) {
            return;
        }

        var p1:TouchPoint = _twoFingerMap.getItemByIndex(0);
        var p2:TouchPoint = _twoFingerMap.getItemByIndex(1);

        if (!p1.target || !_callTwoBackMap[p1]) {
            _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
            _stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

            _twoFingerMap = new ArrayMap();

            return;
        }

        var tc:TouchTwoCallBack = _twoFingerMap[p1.target];

        if (e.type == TouchEvent.TOUCH_END) {
            _twoFingerMap.removeItemById(e.touchPointID);

            if (_twoFingerMap.length < 1) {
                _stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
                _stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

                tc.callEnd();

                setTimeout(function ():void {
                    _twoFingerMap      = new ArrayMap();
                    _twoFingerDragging = false;
                    _twoFingerDelta    = 0;
                }, 300);
            }

            return;
        }

        var delta:Number = Math.abs(p1.stageX - p2.stageX) + Math.abs(p1.stageY - p2.stageY);
        if (!_twoFingerDragging) {
            _twoFingerDragging = delta > _checkDragDis;
        }

        _twoFingerDelta = delta - _twoFingerDelta;
        tc.callMoving(_twoFingerDelta);
    }

}
}


/******************************************************************************************************
 *
 *   内部私有类
 *
 *
 * ****************************************************************************************************/


import flash.display.DisplayObject;
import flash.geom.Point;

import net.play5d.game.bvn.utils.TouchMoveEvent;

/**
 * 一个触点的舞台坐标。
 */
internal class TouchPoint {
    /**
     * 记下触点编号。
     *
     * @param touchId 触点编号。
     */
    public function TouchPoint(touchId:int) {
        this.touchId = touchId;
    }
    /**
     * 触点编号。
     */
    public var touchId:int;
    /**
     * 舞台横坐标。
     *
     * @default 0
     */
    public var stageX:Number        = 0;
    /**
     * 舞台纵坐标。
     *
     * @default 0
     */
    public var stageY:Number        = 0;
    /**
     * 按下时的显示对象。
     *
     * @default null
     */
    public var target:DisplayObject = null;

}

/**
 * 单指回调。回调为 null 时，开始、移动和结束都不调用。
 *
 * <p>两个方向都参加时，距离是横向绝对值加纵向绝对值。只开横向时只用横向。只开纵向，或两个都关时，看的是纵向位移本身是不是 0，不是 <code>dragY</code>。</p>
 */
internal class TouchCallBack {
    /**
     * 记下回调和参与距离的方向。
     *
     * @param back 回调。null 时之后的调用直接返回。
     * @param dragX 是否计入横向。默认 true。
     * @param dragY 是否计入纵向。默认 true。实际距离见类说明。
     */
    public function TouchCallBack(back:Function, dragX:Boolean = true, dragY:Boolean = true) {
        this.callback = back;
        this.dragX    = dragX;
        this.dragY    = dragY;
    }
    private var callback:Function;
    private var dragX:Boolean;
    private var dragY:Boolean;
    private var _startX:Number;
    private var _startY:Number;

    /**
     * 发送按下，并记下起点。回调为 null 时直接返回。
     *
     * @param startX 舞台横坐标。
     * @param startY 舞台纵坐标。
     * @example
     * <listing version="3.0">
     * call.callBegin(x, y);
     * </listing>
     */
    public function callBegin(startX:Number, startY:Number):void {
        _startX = startX;
        _startY = startY;

        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_BEGIN);
        event.startX             = startX;
        event.startY             = startY;

        callback(event);
    }

    /**
     * 发送抬起。距离是终点减起点。回调为 null 时直接返回。
     *
     * @param endX 舞台横坐标。
     * @param endY 舞台纵坐标。
     * @example
     * <listing version="3.0">
     * call.callEnd(x, y);
     * </listing>
     */
    public function callEnd(endX:Number, endY:Number):void {
        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_END);
        event.startX             = _startX;
        event.startY             = _startY;
        event.endX               = endX;
        event.endY               = endY;

        event.distanceX = event.endX - event.startX;
        event.distanceY = event.endY - event.startY;

        callback(event);
    }

    /**
     * 发送移动，把传入的位移写进事件。回调为 null 时直接返回。
     *
     * @param deltaX 横向位移。
     * @param deltaY 纵向位移。
     * @example
     * <listing version="3.0">
     * call.callMoving(dx, dy);
     * </listing>
     */
    public function callMoving(deltaX:Number, deltaY:Number):void {
        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_MOVE);
        event.startX             = _startX;
        event.startY             = _startY;

        event.deltaX = deltaX;
        event.deltaY = deltaY;

        callback(event);
    }

    /**
     * 计算这一帧算不算开始拖。两个方向都开时是横向绝对值加纵向绝对值。只开横向时只用横向。只开纵向或两个都关时，纵向位移为 0 则返回 0，否则返回纵向绝对值。
     *
     * @param deltaX 横向位移。
     * @param deltaY 纵向位移。
     * @return 用来和阈值比较的距离。
     * @example
     * <listing version="3.0">
     * var distance:Number = call.getDragDistance(dx, dy);
     * </listing>
     */
    public function getDragDistance(deltaX:Number, deltaY:Number):Number {

        if (dragX && dragY) {
            return Math.abs(deltaX) + Math.abs(deltaY);
        }

        if (dragX) {
            return Math.abs(deltaX);
        }

        if (deltaY) {
            return Math.abs(deltaY);
        }

        return 0;
    }

}


/**
 * 双指回调。回调为 null 时，开始、移动和结束都不调用。开始和结束事件不写坐标。
 */
internal class TouchTwoCallBack {
    /**
     * 记下回调。
     *
     * @param back 回调。null 时之后的调用直接返回。
     */
    public function TouchTwoCallBack(back:Function) {
        this.callback = back;
    }
    private var callback:Function;

    /**
     * 发送按下。不写起点。回调为 null 时直接返回。
     *
     * @example
     * <listing version="3.0">
     * call.callBegin();
     * </listing>
     */
    public function callBegin():void {

        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_BEGIN);
        callback(event);
    }

    /**
     * 发送抬起。不写终点。回调为 null 时直接返回。
     *
     * @example
     * <listing version="3.0">
     * call.callEnd();
     * </listing>
     */
    public function callEnd():void {
        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_END);
        callback(event);
    }

    /**
     * 发送移动，只写入 <code>delta</code>。回调为 null 时直接返回。
     *
     * @param delta 间距变化。
     * @example
     * <listing version="3.0">
     * call.callMoving(delta);
     * </listing>
     */
    public function callMoving(delta:Number):void {
        if (callback == null) {
            return;
        }

        var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_MOVE);
        event.delta              = delta;
        callback(event);
    }

    /**
     * 固定返回 0。舞台上的双指距离不走这个方法。
     *
     * @param pointA 第一点。不使用。
     * @param pointB 第二点。不使用。
     * @return 固定 0。
     * @example
     * <listing version="3.0">
     * var distance:Number = call.getDragDistance(a, b);
     * </listing>
     */
    public function getDragDistance(pointA:Point, pointB:Point):Number {

        return 0;
    }

}
