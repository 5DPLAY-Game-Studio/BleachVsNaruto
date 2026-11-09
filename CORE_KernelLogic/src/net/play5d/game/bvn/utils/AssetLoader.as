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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.net.URLRequest;

import net.play5d.game.bvn.interfaces.IAssetLoader;
import net.play5d.kyo.loader.KyoLoaderLite;
import net.play5d.kyo.loader.KyoURLLoader;

/**
 * 从 <code>assets/</code> 加载资源。地址前面固定加上这段，不再判断是不是已经带了。
 *
 * <p><code>dispose</code> 和 <code>loadPreLoad</code> 是空的。<code>needPreLoad</code> 固定返回 false。XML 解析失败直接抛出，不会走失败回调。JSON 解析失败会记日志，并在失败回调存在时不带参数调用它。</p>
 */
public class AssetLoader implements IAssetLoader {

    /**
     * 加载 XML。成功时把解析结果交给 <code>back</code>。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @param back 成功回调，参数是 <code>XML</code>。为 null 时成功后抛错。
     * @param fail 失败回调。默认 null。解析失败不会调用它。
     * @throws TypeError 成功时回调为 null。
     * @throws Error 内容不是合法 XML 时。
     * @example
     * <listing version="3.0">
     * loader.loadXML('data/a.xml', onXml);
     * </listing>
     */
    public function loadXML(url:String, back:Function, fail:Function = null):void {
        url = getFullUrl(url);

        KyoURLLoader.load(url, function (data:String):void {
            back(new XML(data));
        }, fail);
    }

    /**
     * 加载 JSON。解析失败时调用失败回调，不把异常再抛出。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @param back 成功回调，参数是解析后的对象。为 null 时成功后抛错。
     * @param fail 网络失败或解析失败时调用，不带参数。默认 null。
     * @throws TypeError 解析成功时回调为 null。
     * @example
     * <listing version="3.0">
     * loader.loadJSON('data/a.json', onJson, onFail);
     * </listing>
     */
    public function loadJSON(url:String, back:Function, fail:Function = null):void {
        url = getFullUrl(url);

        KyoURLLoader.load(url, function (data:String):void {
            try {
                var json:Object = JSON.parse(data);
                back(json);
            }
            catch (e:Error) {
                GameLogger.error('load', String(e));
                if (fail != null) {
                    fail();
                }
            }

        }, fail);
    }

    /**
     * 加载 SWF，回调原样交给加载器。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @example
     * <listing version="3.0">
     * loader.loadSwf('ui/a.swf', onSwf);
     * </listing>
     */
    public function loadSwf(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        url = getFullUrl(url);
        KyoLoaderLite.loadLoader(url, back, fail, progress);
    }

    /**
     * 加载位图，回调原样交给加载器。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @param back 成功回调。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @example
     * <listing version="3.0">
     * loader.loadBitmap('img/a.png', onBitmap);
     * </listing>
     */
    public function loadBitmap(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        url = getFullUrl(url);
        KyoLoaderLite.load(url, back, fail, progress);

    }

    /**
     * 加载声音。完成时把 <code>Sound</code> 交给回调。进度是已加载字节除以总字节，总字节为 0 时这个比值没有意义。
     *
     * @param url 相对 <code>assets/</code> 的地址。
     * @param back 成功回调，参数是 <code>Sound</code>。为 null 时完成后抛错。
     * @param fail 失败回调，不带参数。默认 null。
     * @param progress 进度回调，参数是比值。默认 null。
     * @throws TypeError 完成时回调为 null。
     * @example
     * <listing version="3.0">
     * loader.loadSound('snd/a.mp3', onSound);
     * </listing>
     */
    public function loadSound(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        url = getFullUrl(url);

        var s:Sound = new Sound();
        s.addEventListener(Event.COMPLETE, onComplete);
        s.addEventListener(IOErrorEvent.IO_ERROR, onError);
        s.addEventListener(ProgressEvent.PROGRESS, onProgress);

        s.load(new URLRequest(url));

        function clear():void {
            s.removeEventListener(Event.COMPLETE, onComplete);
            s.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            s.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        function onComplete(e:Event):void {
            back(s);
            clear();
        }

        function onError(e:IOErrorEvent):void {
            if (fail != null) {
                fail();
            }
            clear();
        }

        function onProgress(e:ProgressEvent):void {
            if (progress != null) {
                progress(e.bytesLoaded / e.bytesTotal);
            }
        }

    }

    /**
     * 空实现。地址不会被卸载。
     *
     * @param url 地址。不使用。
     * @example
     * <listing version="3.0">
     * loader.dispose(url);
     * </listing>
     */
    public function dispose(url:String):void {
    }

    /**
     * 是否需要预加载。
     *
     * @return 固定 false。
     * @example
     * <listing version="3.0">
     * var need:Boolean = loader.needPreLoad();
     * </listing>
     */
    public function needPreLoad():Boolean {
        return false;
    }

    /**
     * 空实现。成功、失败和进度回调都不会被调用。
     *
     * @param back 成功回调。不使用。
     * @param fail 失败回调。默认 null。
     * @param progress 进度回调。默认 null。
     * @example
     * <listing version="3.0">
     * loader.loadPreLoad(onDone);
     * </listing>
     */
    public function loadPreLoad(back:Function, fail:Function = null, progress:Function = null):void {

    }

    private static function getFullUrl(url:String):String {
        return 'assets/' + url;
    }

}
}
