/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.fighter.api.v1 {
import net.play5d.game.bvn.fighter.ctrler.FighterCameraCtrler;

/**
 * 角色时间轴第 1 版镜头门面。
 *
 * <p>聚焦三个方法，以及当前注入对象从镜头控制器继承、时间轴能够直接调到的操纵方法。调用原样转发。绑定目标、销毁和场景尺寸留在控制器。</p>
 *
 * @see FighterCameraCtrler
 */
public class FighterCameraApi {

    /** @private */
    private var _camera:FighterCameraCtrler;

    /**
     * 绑定要转发的镜头控制器。
     *
     * @param camera 角色镜头控制器。
     * @example
     * <listing version="3.0">
     * var api:FighterCameraApi = new FighterCameraApi(camera);
     * </listing>
     */
    public function FighterCameraApi(camera:FighterCameraCtrler) {
        _camera = camera;
    }

    /**
     * 聚焦给定对象。
     *
     * @param focusParam 精灵或精灵数组。
     * @param noTween 是否跳过缓动。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.focus(fighter, false);
     * </listing>
     */
    public function focus(focusParam:Object, noTween:Boolean = false):void {
        _camera.focus(focusParam, noTween);
    }

    /**
     * 聚焦自身。
     *
     * @param noTween 是否跳过缓动。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.focusSelf();
     * </listing>
     */
    public function focusSelf(noTween:Boolean = false):void {
        _camera.focusSelf(noTween);
    }

    /**
     * 聚焦当前目标。
     *
     * @param noTween 是否跳过缓动。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.focusTarget();
     * </listing>
     */
    public function focusTarget(noTween:Boolean = false):void {
        _camera.focusTarget(noTween);
    }

    /**
     * 设置缓动速度。
     *
     * @param tweenSpd 缓动速度。
     * @example
     * <listing version="3.0">
     * api.setTweenSpd(5);
     * </listing>
     */
    public function setTweenSpd(tweenSpd:int):void {
        _camera.setTweenSpd(tweenSpd);
    }

    /**
     * 读取缓动速度。
     *
     * @return 缓动速度。
     * @example
     * <listing version="3.0">
     * api.getTweenSpd();
     * </listing>
     */
    public function getTweenSpd():int {
        return _camera.getTweenSpd();
    }

    /**
     * 设置焦点是否跟随 X 轴。
     *
     * @param focusX 是否跟随。默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * api.setFocusX(true);
     * </listing>
     */
    public function setFocusX(focusX:Boolean = true):void {
        _camera.setFocusX(focusX);
    }

    /**
     * 设置焦点是否跟随 Y 轴。
     *
     * @param focusY 是否跟随。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.setFocusY(false);
     * </listing>
     */
    public function setFocusY(focusY:Boolean = false):void {
        _camera.setFocusY(focusY);
    }

    /**
     * 设置焦点 X 偏移。
     *
     * @param offsetX 偏移。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.setOffsetX(0);
     * </listing>
     */
    public function setOffsetX(offsetX:Number = 0):void {
        _camera.setOffsetX(offsetX);
    }

    /**
     * 设置焦点 Y 偏移。
     *
     * @param offsetY 偏移。默认 <code>0</code>。
     * @example
     * <listing version="3.0">
     * api.setOffsetY(0);
     * </listing>
     */
    public function setOffsetY(offsetY:Number = 0):void {
        _camera.setOffsetY(offsetY);
    }

    /**
     * 设置是否自动缩放。
     *
     * @param autoZoom 是否自动缩放。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * api.setAutoZoom(false);
     * </listing>
     */
    public function setAutoZoom(autoZoom:Boolean = false):void {
        _camera.setAutoZoom(autoZoom);
    }

    /**
     * 设置自动缩放下限。
     *
     * @param autoZoomMin 下限。默认 <code>1</code>。
     * @example
     * <listing version="3.0">
     * api.setAutoZoomMin(1);
     * </listing>
     */
    public function setAutoZoomMin(autoZoomMin:Number = 1):void {
        _camera.setAutoZoomMin(autoZoomMin);
    }

    /**
     * 读取自动缩放下限。
     *
     * @return 下限。
     * @example
     * <listing version="3.0">
     * api.getAutoZoomMin();
     * </listing>
     */
    public function getAutoZoomMin():Number {
        return _camera.getAutoZoomMin();
    }

    /**
     * 设置自动缩放上限。
     *
     * @param autoZoomMax 上限。默认 <code>3</code>。
     * @example
     * <listing version="3.0">
     * api.setAutoZoomMax(3);
     * </listing>
     */
    public function setAutoZoomMax(autoZoomMax:Number = 3):void {
        _camera.setAutoZoomMax(autoZoomMax);
    }

    /**
     * 读取缩放倍数。
     *
     * @param withTween 是否带缓动中的值。默认 <code>false</code>。
     * @return 缩放倍数。
     * @example
     * <listing version="3.0">
     * api.getZoom();
     * </listing>
     */
    public function getZoom(withTween:Boolean = false):Number {
        return _camera.getZoom(withTween);
    }

    /**
     * 设置缩放倍数。
     *
     * @param zoom 缩放倍数。
     * @example
     * <listing version="3.0">
     * api.setZoom(1);
     * </listing>
     */
    public function setZoom(zoom:Number):void {
        _camera.setZoom(zoom);
    }

    /**
     * 按偏移移动镜头。
     *
     * @param x 横向偏移。
     * @param y 纵向偏移。
     * @example
     * <listing version="3.0">
     * api.move(10, 0);
     * </listing>
     */
    public function move(x:Number, y:Number):void {
        _camera.move(x, y);
    }

    /**
     * 镜头回到中心。
     *
     * @example
     * <listing version="3.0">
     * api.moveCenter();
     * </listing>
     */
    public function moveCenter():void {
        _camera.moveCenter();
    }

    /**
     * 设置镜头 X。
     *
     * @param x 坐标。
     * @example
     * <listing version="3.0">
     * api.setX(0);
     * </listing>
     */
    public function setX(x:Number):void {
        _camera.setX(x);
    }

    /**
     * 设置镜头 Y。
     *
     * @param y 坐标。
     * @example
     * <listing version="3.0">
     * api.setY(0);
     * </listing>
     */
    public function setY(y:Number):void {
        _camera.setY(y);
    }

}
}
