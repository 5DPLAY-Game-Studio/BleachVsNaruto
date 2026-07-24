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

package net.play5d.game.bvn.interfaces {

/**
 * 素材加载器接口。
 *
 * <p>统一 XML / JSON / SWF / 声音 / 位图等资源的异步加载与释放约定。</p>
 */
public interface IAssetLoader {

    /**
     * 加载 XML 资源。
     *
     * @param url 资源路径。
     * @param back 成功回调。
     * @param fail 失败回调。
     */
    function loadXML(url:String, back:Function, fail:Function = null):void;

    /**
     * 加载 JSON 资源。
     *
     * @param url 资源路径。
     * @param back 成功回调。
     * @param fail 失败回调。
     */
    function loadJSON(url:String, back:Function, fail:Function = null):void;

    /**
     * 加载 SWF 资源。
     *
     * @param url 资源路径。
     * @param back 成功回调。
     * @param fail 失败回调。
     * @param process 进度回调。
     */
    function loadSwf(url:String, back:Function, fail:Function = null, process:Function = null):void;

    /**
     * 加载声音资源。
     *
     * @param url 资源路径。
     * @param back 成功回调。
     * @param fail 失败回调。
     * @param process 进度回调。
     */
    function loadSound(url:String, back:Function, fail:Function = null, process:Function = null):void;

    /**
     * 加载位图资源。
     *
     * @param url 资源路径。
     * @param back 成功回调。
     * @param fail 失败回调。
     * @param process 进度回调。
     */
    function loadBitmap(url:String, back:Function, fail:Function = null, process:Function = null):void;

    /**
     * 释放资源。
     *
     * @param url 资源路径。
     */
    function dispose(url:String):void;

    /**
     * 是否需要预载。
     *
     * @return 需要预载时为 <code>true</code>。
     */
    function needPreLoad():Boolean;

    /**
     * 加载预载资源。
     *
     * @param back 成功回调。
     * @param fail 失败回调。
     * @param process 进度回调。
     */
    function loadPreLoad(back:Function, fail:Function = null, process:Function = null):void;
}
}
