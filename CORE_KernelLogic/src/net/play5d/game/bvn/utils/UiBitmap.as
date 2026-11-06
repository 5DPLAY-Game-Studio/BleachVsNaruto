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

package net.play5d.game.bvn.utils {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;

import net.play5d.kyo.loader.KyoLoaderLite;

/**
 * 从 <code>assets/ui/bitmap</code> 读取界面图片。
 *
 * <p>同一文件只请求一次。每次取出的是位图副本，调用方可以单独释放。</p>
 *
 * @see #load()
 * @see #create()
 */
public class UiBitmap {

    /** @private */
    private static const _root:String = 'assets/ui/bitmap/';
    /** @private 文件名到已载入的位图数据 */
    private static var _data:Object    = {};

    /**
     * 读取一张图片。已经在缓存里时直接回调。
     *
     * @param name 文件名，如 <code>startup.png</code>。
     * @param back 成功回调，参数为位图副本。
     * @param fail 失败回调。可省略。
     * @example
     * <listing version="3.0">
     * UiBitmap.load('startup.png', onPic, onFail);
     * </listing>
     */
    public static function load(name:String, back:Function, fail:Function = null):void {
        if (_data[name]) {
            back(create(name));
            return;
        }

        KyoLoaderLite.load(_root + name, function (display:DisplayObject):void {
            var bmp:Bitmap = display as Bitmap;
            if (!bmp || !bmp.bitmapData) {
                if (fail != null) {
                    fail();
                }
                return;
            }

            _data[name] = bmp.bitmapData;
            back(create(name));
        }, function ():void {
            if (fail != null) {
                fail();
            }
        }, null);
    }

    /**
     * 读取一组图片，全部成功后回调一次。
     *
     * @param names 文件名列表。
     * @param back 全部成功回调。
     * @param fail 任一失败回调，只调用一次。可省略。
     * @example
     * <listing version="3.0">
     * UiBitmap.loadAll(['arrow.png', 'attack.png'], onReady, onFail);
     * </listing>
     */
    public static function loadAll(names:Array, back:Function, fail:Function = null):void {
        var left:int       = names.length;
        var failed:Boolean = false;
        if (left == 0) {
            back();
            return;
        }

        for each(var name:String in names) {
            load(name, function (bmp:Bitmap):void {
                if (failed) {
                    return;
                }
                left--;
                if (left == 0 && back != null) {
                    back();
                }
            }, function ():void {
                if (failed) {
                    return;
                }
                failed = true;
                if (fail != null) {
                    fail();
                }
            });
        }
    }

    /**
     * 从缓存复制一张图片。
     *
     * @param name 文件名。
     * @return 位图副本。还没载入时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var bmp:Bitmap = UiBitmap.create('cancel.png');
     * </listing>
     */
    public static function create(name:String):Bitmap {
        var src:BitmapData = _data[name] as BitmapData;
        if (!src) {
            return null;
        }

        return new Bitmap(src.clone(), 'auto', true);
    }

}
}
