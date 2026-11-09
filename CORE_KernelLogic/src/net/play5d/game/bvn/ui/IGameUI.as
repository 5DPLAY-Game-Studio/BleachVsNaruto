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

package net.play5d.game.bvn.ui {
import flash.display.DisplayObject;

/**
 * 对局界面。连击编号不是 1 时走另一侧。没有暂停界面时 <code>resume</code> 返回 true。
 */
public interface IGameUI {
    /**
     * 设置界面音量。
     *
     * @param v 音量。
     */
    function setVolume(v:Number):void;

    /**
     * 释放界面。
     */
    function destroy():void;

    /**
     * 显示界面。
     *
     * @param animate 默认 true，播放进入。
     */
    function fadeIn(animate:Boolean = true):void;

    /**
     * 藏起界面。
     *
     * @param animate 默认 true，播放离开。
     */
    function fadeOut(animate:Boolean = true):void;

    /**
     * 界面显示对象。
     *
     * @return 显示对象。
     */
    function getUI():DisplayObject;

    /**
     * 推进逻辑帧。
     */
    function render():void;

    /**
     * 推进动画帧。
     */
    function renderAnimate():void;

    /**
     * 显示连击数。
     *
     * @param hits 连击数。
     * @param id 1 是一侧，其它编号是另一侧。
     */
    function showHits(hits:int, id:int):void;

    /**
     * 藏起连击数。
     *
     * @param id 1 是一侧，其它编号是另一侧。
     */
    function hideHits(id:int):void;

    /**
     * 播放开场。
     *
     * @param finishBack 播完回调。默认 null。
     * @param params 额外参数。默认 null。
     */
    function showStart(finishBack:Function = null, params:Object = null):void;

    /**
     * 播放结束。
     *
     * @param finishBack 播完回调。默认 null。
     * @param params 额外参数。默认 null。
     */
    function showEnd(finishBack:Function = null, params:Object = null):void;

    /**
     * 显示继续按钮。没有界面时可以直接返回。
     *
     * @param onClick 按下后的回调。
     */
    function showContinue(onClick:Function):void;

    /**
     * 清掉开场和结束动画。
     */
    function clearStartAndEnd():void;

    /**
     * 打开暂停。
     */
    function pause():void;

    /**
     * 关闭暂停。
     *
     * @return 没有暂停界面时为 true，否则是隐藏暂停的结果。
     */
    function resume():Boolean;
}
}
