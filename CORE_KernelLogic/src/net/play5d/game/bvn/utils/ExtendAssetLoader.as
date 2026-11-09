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
import net.play5d.game.bvn.interfaces.IAssetLoader;

/**
 * 把加载调用转给外部对象。扩展对象为 null 时，调试环境抛出 <code>Error</code> 并返回；发行环境只记日志，字段留空，之后的调用会抛错。
 */
public class ExtendAssetLoader implements IAssetLoader {

    /**
     * 记下外部加载器。
     *
     * @param extend 实现了同样加载方法的对象。null 时见类说明。
     * @throws Error 调试环境且扩展对象为 null 时。
     */
    public function ExtendAssetLoader(extend:*) {
        if (!extend) {
            ThrowError(Error, 'extend is null !');
            return;
        }
        _extend = extend;
    }
    private var _extend:*;

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadXML(url, onXml);
     * </listing>
     */
    public function loadXML(url:String, back:Function, fail:Function = null):void {
        _extend.loadXML(url, back, fail);
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadJSON(url, onJson);
     * </listing>
     */
    public function loadJSON(url:String, back:Function, fail:Function = null):void {
        _extend.loadJSON(url, back, fail);
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadSwf(url, onSwf);
     * </listing>
     */
    public function loadSwf(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _extend.loadSwf(url, back, fail, progress);
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadSound(url, onSound);
     * </listing>
     */
    public function loadSound(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _extend.loadSound(url, back, fail, progress);
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadBitmap(url, onBitmap);
     * </listing>
     */
    public function loadBitmap(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        _extend.loadBitmap(url, back, fail, progress);
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param url 地址。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.dispose(url);
     * </listing>
     */
    public function dispose(url:String):void {
        _extend.dispose(url);
    }

    /**
     * 转给扩展对象的同名方法。
     *
     * @return 扩展对象的返回值。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * var need:Boolean = loader.needPreLoad();
     * </listing>
     */
    public function needPreLoad():Boolean {
        return _extend.needPreLoad();
    }

    /**
     * 转给扩展对象的同名方法。扩展对象为空时抛错。
     *
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @throws TypeError 扩展对象为空时。
     * @example
     * <listing version="3.0">
     * loader.loadPreLoad(onDone);
     * </listing>
     */
    public function loadPreLoad(back:Function, fail:Function = null, progress:Function = null):void {
        _extend.loadPreLoad(back, fail, progress);
    }
}
}
