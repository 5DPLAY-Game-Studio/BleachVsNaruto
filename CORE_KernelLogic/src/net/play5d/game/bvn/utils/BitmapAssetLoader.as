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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;

import net.play5d.game.bvn.ctrler.AssetManager;

/**
 * 按队列加载位图。某一张失败或不是位图时记日志并继续下一张，队列仍会走完。
 *
 * <p>取图时每次新建一个 <code>Bitmap</code>，像素仍是缓存里的同一份。<code>loadQueue</code> 进行中再调一次，会换掉队列和回调，进行中的那张完成后继续走新队列。</p>
 */
public class BitmapAssetLoader {

    private var _queueLength:int;
    private var _urls:Array;
    private var _cacheObj:Object = {};
    private var _successBack:Function;
    private var _progressBack:Function;

    /**
     * 按地址取出一张新位图。还没缓存时返回 null。
     *
     * @param id 加载时用的地址。
     * @return 新的位图。没有缓存时为 null。
     * @example
     * <listing version="3.0">
     * var bmp:Bitmap = loader.getBitmap(url);
     * </listing>
     */
    public function getBitmap(id:String):Bitmap {

        var bd:BitmapData = _cacheObj[id];
        if (bd == null) {
            return null;
        }
        return new Bitmap(bd);
    }

    /**
     * 按数组顺序加载。空数组会立刻调用成功回调。进度是已完成张数加上当前这张的进度，再除以总数。
     *
     * @param urls 地址数组。null 时抛错。内容会被复制。
     * @param success 全部走完时调用，不带参数。为 null 时走完也不调用。
     * @param progress 进度回调，参数是 0 到 1 的比值。默认 null。
     * @throws TypeError 地址数组为 null 时。
     * @example
     * <listing version="3.0">
     * loader.loadQueue(urls, onDone, onProgress);
     * </listing>
     */
    public function loadQueue(urls:Array, success:Function, progress:Function = null):void {
        _successBack  = success;
        _progressBack = progress;

        _urls        = urls.concat();
        _queueLength = urls.length;
        loadNext();
    }

    private function load(url:String, back:Function = null, progress:Function = null):void {
        AssetManager.I.loadBitmap(url, loadCom, loadFail, progress);

        function loadCom(bp:DisplayObject):void {
            cacheBitmap(url, bp);
            if (back != null) {
                back();
            }
        }

        function loadFail():void {
            GameLogger.error('load', 'BitmapAssetLoader.loadFail: ' + url);
            if (back != null) {
                back();
            }
        }

    }

    private function cacheBitmap(id:String, bp:DisplayObject):void {
        var content:Bitmap = bp as Bitmap;

        if (!content) {
            GameLogger.error('load', 'BitmapAssetLoader.cacheBitmap Error');
            return;
        }

        var cache:BitmapData;

        if (content) {
            try {
                cache = content.bitmapData;
            }
            catch (e:Error) {
                GameLogger.error('load', 'BitmapAssetLoader.cacheBitmap: ' + e);
            }
        }
        else {
        }

        if (cache) {
            _cacheObj[id] = cache;
        }

        AssetManager.I.disposeAsset(id);

    }

    private function loadNext():void {
        if (_urls.length < 1) {
            _progressBack = null;
            if (_successBack != null) {
                _successBack();
                _successBack = null;
            }

            return;
        }
        var url:String = _urls.shift();
        load(url, loadNext, loadProgress);

        function loadProgress(v:Number):void {
            if (_progressBack != null) {
                var cur:Number = _queueLength - _urls.length - 1 + v;
                var p:Number   = cur / _queueLength;
                _progressBack(p);
            }
        }

    }

}
}
