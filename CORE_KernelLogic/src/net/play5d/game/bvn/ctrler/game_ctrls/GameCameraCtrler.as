/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ctrler.game_ctrls {
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.interfaces.IGameSprite;

import net.play5d.game.bvn.stage.GameCamera;

/**
 * 游戏镜头控制器
 */
public class GameCameraCtrler {
    include '../../../../../../../include/_INCLUDE_.as';

    // 游戏镜头实例
    private var _camera:GameCamera;

    public function GameCameraCtrler(camera:GameCamera) {
        setCamera(camera);
    }

    /**
     * 设置镜头实例
     *
     * @param camera 镜头实例
     */
    public function setCamera(camera:GameCamera):void {
        _camera = camera;
    }

    /**
     * 获取镜头实例
     *
     * @return 镜头实例
     */
    public function getCamera():GameCamera {
        return _camera;
    }

    /**
     * 销毁
     *
     * @param destroyCamera 是否同时销毁镜头
     */
    public function destroy(destroyCamera:Boolean = false):void {
        if (destroyCamera && _camera) {
            _camera.destroy();
            _camera = null;
        }
    }

//    public function render():void {
//        _camera.render();
//    }

    //////////////////////////////////////////////////////////////////////////////////////////

    /**
     * 设置镜头的缓动速度
     *
     * @param tweenSpd 镜头的缓动速度
     */
    public function setTweenSpd(tweenSpd:int):void {
        _camera.tweenSpd = tweenSpd;
    }

    /**
     * 获取镜头的缓动速度
     *
     * @return tweenSpd 镜头的缓动速度
     */
    public function getTweenSpd():int {
        return _camera.tweenSpd;
    }

    /**
     * 设置镜头显示场景大小
     *
     * @param stageSize 镜头显示场景大小
     */
    public function setStageSize(stageSize:Point):void {
        _camera.stageSize = stageSize;
    }

    /**
     * 设置焦点是否跟随 X 轴
     *
     * @param focusX 焦点是否跟随 X 轴
     */
    public function setFocusX(focusX:Boolean = true):void {
        _camera.focusX = focusX;
    }

    /**
     * 设置焦点是否跟随 Y 轴
     *
     * @param focusY 焦点是否跟随 Y 轴
     */
    public function setFocusY(focusY:Boolean = false):void {
        _camera.focusY = focusY;
    }

    /**
     * 设置焦点的 X 坐标偏移
     *
     * @param offsetX 焦点的 X 坐标偏移
     */
    public function setOffsetX(offsetX:Number = 0):void {
        _camera.offsetX = offsetX;
    }

    /**
     * 设置焦点的 Y 坐标偏移
     *
     * @param offsetY 焦点的 Y 坐标偏移
     */
    public function setOffsetY(offsetY:Number = 0):void {
        _camera.offsetY = offsetY;
    }

    /**
     * 设置镜头是否自动缩放
     *
     * @param autoZoom 镜头是否自动缩放
     */
    public function setAutoZoom(autoZoom:Boolean = false):void {
        _camera.autoZoom = autoZoom;
    }

    /**
     * 设置镜头自动缩放的最小比例
     *
     * @param autoZoomMin 镜头自动缩放的最小比例
     */
    public function setAutoZoomMin(autoZoomMin:Number = 1):void {
        _camera.autoZoomMin = autoZoomMin;
    }
    /**
     * 获取镜头自动缩放的最小比例
     *
     * @return 镜头自动缩放的最小比例
     */
    public function getAutoZoomMin():Number {
        return _camera.autoZoomMin;
    }

    /**
     * 设置镜头自动缩放的最大比例
     *
     * @param autoZoomMax 镜头自动缩放的最大比例
     */
    public function setAutoZoomMax(autoZoomMax:Number = 3):void {
        _camera.autoZoomMax = autoZoomMax;
    }

    //////////////////////////////////////////////////////////////////////////////////////////

    /**
     * 获取屏幕矩形
     *
     * @param withTween 是否包含补间
     *
     * @return 屏幕矩形
     */
    public function getScreenRect(withTween:Boolean = false):Rectangle {
        return _camera.getScreenRect(withTween);
    }

    /**
     * 现在立即更新镜头
     */
    public function updateNow():void {
        _camera.updateNow();
    }

    /**
     * 设置场景边界
     *
     * @param rect 场景边界
     */
    public function setStageBounds(rect:Rectangle = null):void {
        _camera.setStageBounds(rect);
    }

    /**
     * 通过显示对象设置场景大小
     *
     * @param display 指定显示对象
     */
    public function setStageSizeFromDisplay(display:DisplayObject):void {
        _camera.setStageSizeFromDisplay(display);
    }

    /**
     * 获取镜头缩放倍数
     *
     * @param withTween 是否包括补间
     *
     * @return 镜头缩放倍数
     */
    public function getZoom(withTween:Boolean = false):Number {
        return _camera.getZoom(withTween);
    }

    /**
     * 设置镜头缩放倍数
     *
     * @param zoom 镜头缩放倍数
     */
    public function setZoom(zoom:Number):void {
        _camera.setZoom(zoom);
    }

    /**
     * 镜头聚焦
     *
     * @param focusParam 要聚焦的显示对象数组
     * @param noTween 是否不进行补间
     */
    public function focus(focusParam:Object, noTween:Boolean = false):void {
        var focusArr:Array = focusParam is Array ? focusParam as Array : null;
        _camera.focus(focusArr, noTween);
    }

    /**
     * 镜头移动
     *
     * @param x 水平移动 X 轴距离
     * @param y 垂直移动 Y 轴距离
     */
    public function move(x:Number, y:Number):void {
        _camera.move(x, y);
    }

    /**
     * 镜头移动到中心
     */
    public function moveCenter():void {
        _camera.moveCenter();
    }

    /**
     * 设置镜头 X 坐标
     *
     * @param x X 坐标
     */
    public function setX(x:Number):void {
        _camera.setX(x);
    }

    /**
     * 设置镜头 Y 坐标
     *
     * @param y Y 坐标
     */
    public function setY(y:Number):void {
        _camera.setY(y);
    }
}
}
