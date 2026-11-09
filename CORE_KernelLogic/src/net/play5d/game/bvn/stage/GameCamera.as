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

package net.play5d.game.bvn.stage {
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 滚动并缩放一个显示对象的镜头。
 *
 * <p>缓动除数大于 1 才慢慢靠近，否则一帧到位。纵向跟随默认关着。多个焦点只取第一个和最后一个。
 * 修正边缘时，右边界比的是夹取矩形的 <code>width</code>，下边界比的是 <code>height</code>。
 * 目标缩放小于等于 0 时，缓动那一步记错并停在旧比例。</p>
 *
 * @modify 2011.1.26
 * @author kyo
 */
public class GameCamera {

    /**
     * 建立镜头。不传场景尺寸时会在边界还没写好时去读它，因此抛错。
     *
     * <p>画面矩形和缓动矩形都从屏幕尺寸建起。修正边缘为 true 时才分配夹取用的矩形。构造完还要 <code>render</code> 才会写到场景。</p>
     *
     * @param stage 被滚动和缩放的场景。null 时随后取边界会抛错。
     * @param screenSize 屏幕宽高。null 时抛错。
     * @param stageSize 场景尺寸。默认 null，此时走会抛错的那条路径。
     * @param fixBorder 是否把镜头夹在场景内。默认 false。
     * @throws TypeError 屏幕尺寸为 null，或没给场景尺寸时。
     */
    public function GameCamera(stage:DisplayObject, screenSize:Point, stageSize:Point = null,
                               fixBorder:Boolean                                      = false
    ) {
        _stage       = stage;
        _rect        = new Rectangle(0, 0, screenSize.x, screenSize.y);
        _noTweenRect = new Rectangle(0, 0, screenSize.x, screenSize.y);

        _screenSize = new Point(screenSize.x, screenSize.y);
        if (fixBorder) {
            _fbR = new Rectangle();
        }

        this.stageSize = stageSize;
        if (!this.stageSize) {
            setStageSizeFromDisplay(_stage);
        }

        setStageBounds();
    }
    /**
     * 缓动除数。大于 1 才缓动，0 和 1 都是一帧到位。
     *
     * @default 0
     */
    public var tweenSpd:int;
    /**
     * 场景尺寸。移动到中心时用它。null 时 <code>moveCenter</code> 抛错。
     *
     * @default null
     */
    public var stageSize:Point;
    /**
     * 是否跟随X
     */
    public var focusX:Boolean     = true;
    /**
     * 是否跟随纵向。
     *
     * @default false
     */
    public var focusY:Boolean;
    /**
     * 焦点位置偏移X
     */
    public var offsetX:Number     = 0;
    /**
     * 焦点位置偏移Y
     */
    public var offsetY:Number     = 0;
    /**
     * 自动缩放，跟随多个对象的位置，只有一个焦点时无效
     */
    public var autoZoom:Boolean   = false;
    /**
     * 最小比例
     */
    public var autoZoomMin:Number = 1;

    /**
     * 最大比例
     */
    public var autoZoomMax:Number         = 3;
    /** @private 目标缩放 */
    private var _zoom:Number              = 1;
    /** @private 未缓动的画面矩形 */
    private var _noTweenRect:Rectangle;
    /** @private */
    private var _stage:DisplayObject;
    /** @private */
    private var _stageBounds:Rectangle;
    /** @private 缓动后取整的画面矩形 */
    private var _rect:Rectangle;
    /** @private 缓动小数坐标；_rect 只保留像素，scrollRect 才不会每帧重写 */
    private var _easeX:Number             = 0;
    /** @private */
    private var _easeY:Number             = 0;
    /** @private 多个焦点时是中间点，单个焦点时是 null */
    private var _focus:Array;
    /** @private */
    private var _point:Point;
    /** @private 当前已经缓动到的缩放 */
    private var _stageScale:Number        = 1;
    /** @private 修正边缘时的夹取矩形，右和下用的是 width、height 字段本身 */
    private var _fbR:Rectangle;
    /** @private */
    private var _foffsetX:Number          = 0;
    /** @private */
    private var _foffsetY:Number          = 0;
    /** @private */
    private var _screenSize:Point;
    /** @private 上次写入 scrollRect / scale，未变化则跳过赋值 */
    private var _appliedScrollX:Number    = NaN;
    private var _appliedScrollY:Number    = NaN;
    private var _appliedScrollW:Number    = NaN;
    private var _appliedScrollH:Number    = NaN;
    private var _appliedStageScale:Number = NaN;

    /**
     * 丢掉场景、矩形和焦点。之后再 <code>render</code> 写画面会抛错。
     *
     * @example
     * <listing version="3.0">
     * camera.destroy();
     * </listing>
     */
    public function destroy():void {
        stageSize = null;

        _noTweenRect = null;
        _stage = null;
        _stageBounds = null;
        _rect = null;
        _focus = null;
        _point = null;
        _fbR = null;
        _screenSize = null;
    }

    /**
     * 画面矩形。返回的是内部对象。
     *
     * @param withTween 默认 false，返回目标矩形。true 返回缓动后取整的矩形。
     * @return 对应的矩形。销毁后为 null。
     * @example
     * <listing version="3.0">
     * var rect:Rectangle = camera.getScreenRect(true);
     * </listing>
     */
    public function getScreenRect(withTween:Boolean = false):Rectangle {
        return withTween ? _rect : _noTweenRect;
    }

    /**
     * 把缓动临时改成 0，渲染一帧，再改回去。没有焦点也没有目标点时这一帧什么都不写。
     *
     * @example
     * <listing version="3.0">
     * camera.updateNow();
     * </listing>
     */
    public function updateNow():void {
        var oldTweenSpd:Number = tweenSpd;
        tweenSpd               = 0;
        render();
        tweenSpd = oldTweenSpd;
    }

    /**
     * 设置场景边界，并按当前缩放重算画面大小。
     *
     * @param rect 边界。默认 null，改用场景相对自己的边界。传入的矩形按原引用保存。
     * @throws TypeError 场景已销毁，或默认路径下场景为 null 时。
     * @example
     * <listing version="3.0">
     * camera.setStageBounds(rect);
     * </listing>
     */
    public function setStageBounds(rect:Rectangle = null):void {
        if (!rect) {
            _stageBounds = _stage.getBounds(_stage);
        }
        else {
            _stageBounds = rect;
        }
        setZoom(_zoom);
    }

    /**
     * 用显示对象的宽高除以缩放，再加上已有边界的坐标，写成场景尺寸。
     *
     * @param d 显示对象。null，或边界还没建立时抛错。
     * @throws TypeError 显示对象或边界为 null 时。
     * @example
     * <listing version="3.0">
     * camera.setStageSizeFromDisplay(view);
     * </listing>
     */
    public function setStageSizeFromDisplay(d:DisplayObject):void {
        var x:Number = d.width / d.scaleX + _stageBounds.x;
        var y:Number = d.height / d.scaleY + _stageBounds.y;

        stageSize = new Point(x, y);
    }

    /**
     * 缩放。
     *
     * @param withTween 默认 false，返回目标缩放。true 返回已经缓动到的缩放。
     * @return 缩放值。
     * @example
     * <listing version="3.0">
     * var zoom:Number = camera.getZoom(true);
     * </listing>
     */
    public function getZoom(withTween:Boolean = false):Number {
        return withTween ? _stageScale : _zoom;
    }

    /**
     * 设置目标缩放，并重算未缓动的画面大小。场景的 <code>scaleX</code> 要等 <code>render</code> 才写。
     *
     * <p>修正边缘时，夹取矩形的右和下写成边界宽高减去屏幕除以缩放，比较时直接拿这两个字段当坐标上限。</p>
     *
     * @param value 目标缩放。小于等于 0 时，下次缓动缩放会记错并返回，比例停在旧值。
     * @example
     * <listing version="3.0">
     * camera.setZoom(2);
     * </listing>
     */
    public function setZoom(value:Number):void {
        _zoom = value;

        var invZoom:Number = 1 / _zoom;

        _noTweenRect.width  = _screenSize.x * invZoom;
        _noTweenRect.height = _screenSize.y * invZoom;

        _foffsetX = _screenSize.x * 0.5 * invZoom;
        _foffsetY = _screenSize.y * 0.5 * invZoom;

        //边界
        if (_fbR) {
            _fbR.x      = _stageBounds.x * _zoom;
            _fbR.y      = _stageBounds.y * _zoom;
            _fbR.width  = _stageBounds.width - _screenSize.x * invZoom;
            _fbR.height = _stageBounds.height - _screenSize.y * invZoom;
        }
    }

    /**
     * 改跟随目标。超过一个时只取第一个和最后一个的中点。
     *
     * <p>空数组会存下来，下次 <code>render</code> 读第一个元素时抛错。传入 null 立刻抛错。
     * <code>noTween</code> 为 true 时先用 0 缓动渲染一帧再恢复。</p>
     *
     * @param focusArr 显示对象数组。
     * @param noTween 默认 false。
     * @throws TypeError 数组为 null 时。
     * @example
     * <listing version="3.0">
     * camera.focus([a, b], true);
     * </listing>
     */
    public function focus(focusArr:Array, noTween:Boolean = false):void {
        _focus = focusArr;

        _point = _focus.length > 1 ? new Point() : null;

        if (noTween) {
            var tweenBK:int = tweenSpd;
            tweenSpd        = 0;
            render();
            tweenSpd = tweenBK;
        }
    }

    /**
     * 取消跟随，改看这个点。要等 <code>render</code> 才移动。
     *
     * @param x 横坐标。
     * @param y 纵坐标。
     * @example
     * <listing version="3.0">
     * camera.move(100, 40);
     * </listing>
     */
    public function move(x:Number, y:Number):void {
        _focus = null;
        _point = new Point(x, y);
    }

    /**
     * 取消跟随，改看场景中心。场景尺寸为 null 时抛错。
     *
     * @throws TypeError 场景尺寸为 null 时。
     * @example
     * <listing version="3.0">
     * camera.moveCenter();
     * </listing>
     */
    public function moveCenter():void {
        _focus = null;
        _point = new Point(stageSize.x * 0.5, stageSize.y * 0.5);
    }

    /**
     * 按焦点或目标点移动，并把缩放和滚动写到场景。
     *
     * <p>两者都没有时直接返回。纵向跟随默认关着。缩放目标小于等于 0 时这一帧不改比例。</p>
     *
     * @example
     * <listing version="3.0">
     * camera.render();
     * </listing>
     */
    public function render():void {
        if (!_focus && !_point) {
            return;
        }

        if (_focus.length > 1) {
            renderTwo(_focus[0], _focus[_focus.length - 1]);
        }

        if (focusX) {
            renderX();
        }
        if (focusY) {
            renderY();
        }
        if (_stageScale != _zoom) {
            renderZoom();
        }

        //应用设置
        applySet();

    }

    /**
     * 设置横向目标。缓动值大于 1 时逐帧靠近，否则一帧到位。画面横坐标取整。
     *
     * <p>修正边缘时，小于夹取矩形的 x 就改成 x，大于它的 width 就改成 width。</p>
     *
     * @param v 目标横坐标。
     * @example
     * <listing version="3.0">
     * camera.setX(20);
     * </listing>
     */
    public function setX(v:Number):void {

        if (_fbR) {
            if (v < _fbR.x) {
                v = _fbR.x;
            }
            if (v > _fbR.width) {
                v = _fbR.width;
            }
        }

        _noTweenRect.x = v;

        if (tweenSpd > 1) {
            _easeX += (v - _easeX) / tweenSpd;
        }
        else {
            _easeX = v;
        }
        _rect.x = Math.round(_easeX);
    }

    /**
     * 设置纵向目标。缓动和取整与 <code>setX</code> 相同。
     *
     * <p>修正边缘时，小于夹取矩形的 y 就改成 y，大于它的 height 就改成 height。</p>
     *
     * @param v 目标纵坐标。
     * @example
     * <listing version="3.0">
     * camera.setY(10);
     * </listing>
     * @see #setX()
     */
    public function setY(v:Number):void {

        if (_fbR) {
            if (v < _fbR.y) {
                v = _fbR.y;
            }
            if (v > _fbR.height) {
                v = _fbR.height;
            }
        }

        _noTweenRect.y = v;

        if (tweenSpd > 1) {
            _easeY += (v - _easeY) / tweenSpd;
        }
        else {
            _easeY = v;
        }
        _rect.y = Math.round(_easeY);
    }

    /** @private 滚动或缩放和上次不同才写入场景 */
    private function applySet():void {
        if (_appliedScrollX != _rect.x || _appliedScrollY != _rect.y ||
            _appliedScrollW != _rect.width || _appliedScrollH != _rect.height) {
            _appliedScrollX = _rect.x;
            _appliedScrollY = _rect.y;
            _appliedScrollW = _rect.width;
            _appliedScrollH = _rect.height;
            _stage.scrollRect = _rect;
        }
        if (_appliedStageScale != _stageScale) {
            _appliedStageScale = _stageScale;
            _stage.scaleX      = _stage.scaleY = _stageScale;
        }
    }

    /**
     * 计算两者的中间位置
     */
    private function renderTwo(a:DisplayObject, b:DisplayObject):void {
        var distanceX:Number = 0;
        var distanceY:Number = 0;

        if (focusX) {
            var l:DisplayObject, r:DisplayObject;
            if (a.x < b.x) {
                l = a;
                r = b;
            }
            else {
                l = b;
                r = a;
            }
            distanceX = r.x - l.x;
            _point.x  = l.x + distanceX * 0.5;
        }
        if (focusY) {
            var u:DisplayObject, d:DisplayObject;
            if (a.y < b.y) {
                u = a;
                d = b;
            }
            else {
                u = b;
                d = a;
            }
            distanceY = d.y - u.y;
            _point.y  = u.y + distanceY * 0.5;
        }

        if (autoZoom) {
            var zoomX:Number = _zoom;
            var zoomY:Number = _zoom;

            if (focusX) {
                zoomX = _screenSize.x / distanceX * 0.8;
            }
            if (focusY) {
                zoomY = _screenSize.y / distanceY * 0.8;
            }

            var zoom:Number = Math.min(zoomX, zoomY);
            renderAutoZoom(zoom);
        }
    }

    /** @private 自动缩放先夹到最小和最大 */
    private function renderAutoZoom(zoom:Number):void {
        if (zoom < autoZoomMin) {
            zoom = autoZoomMin;
        }
        if (zoom > autoZoomMax) {
            zoom = autoZoomMax;
        }
        setZoom(zoom);
    }

    /** @private 有目标点时用点，否则用第一个焦点 */
    private function renderX():void {
        var fx:Number;
        fx = _point ? _point.x : _focus[0].x;
        fx -= _foffsetX + offsetX;
        setX(fx);
    }

    /** @private 有目标点时用点，否则用第一个焦点 */
    private function renderY():void {
        var fy:Number;
        fy = _point ? _point.y : _focus[0].y;
        fy -= _foffsetY + offsetY;
        setY(fy);
    }

    /** @private 目标缩放小于等于 0 时记错并返回 */
    private function renderZoom():void {
        if (_zoom <= 0) {
            ThrowError(Error, GetLang('log.error.fight.game_camera.zoom_invalid'));
            return;
        }

        if (tweenSpd > 1) {
            _stageScale += (_zoom - _stageScale) / tweenSpd;
        }
        else {
            _stageScale = _zoom;
        }

        var invStageScale:Number = 1 / _stageScale;
        _rect.width  = (_screenSize.x * invStageScale + 1) >> 0;
        _rect.height = (_screenSize.y * invStageScale + 1) >> 0;
    }

}
}
