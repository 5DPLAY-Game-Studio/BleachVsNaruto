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

package net.play5d.game.bvn.fighter.utils {
import flash.display.DisplayObject;
import flash.geom.Rectangle;

/**
 * 按帧号或元件外观缓存区域。
 *
 * <p>帧缓存里放过 <code>null</code> 也算已经定义。按元件取缓存时，空对象会被当成没有。
 * 缓存键是名字加上位置、宽高和旋转。销毁后再查会抛错。</p>
 */
public class McAreaCacher {

    /**
     * 记下缓存名。
     *
     * @param name 这组缓存的名字。
     * @example
     * <listing version="3.0">
     * var cache:McAreaCacher = new McAreaCacher(name);
     * </listing>
     */
    public function McAreaCacher(name:String) {
        this.name = name;
    }
    /**
     * 缓存名。
     *
     * @default null
     */
    public var name:String;
    /** @private */
    private var _idCache:Object    = {};
    /** @private */
    private var _frameCache:Object = {};

    /**
     * 丢掉两份缓存。
     *
     * @example
     * <listing version="3.0">
     * cache.destroy();
     * </listing>
     */
    public function destroy():void {
        _idCache    = null;
        _frameCache = null;
    }

    /**
     * 这一帧是否已经写过缓存。写过 <code>null</code> 也算写过。
     *
     * @param frame 帧号。
     * @return 写过时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var defined:Boolean = cache.areaFrameDefined(frame);
     * </listing>
     */
    public function areaFrameDefined(frame:int):Boolean {
        return _frameCache[frame] !== undefined;
    }

    /**
     * 取这一帧的缓存。没有时为 <code>undefined</code>。
     *
     * @param frame 帧号。
     * @return 缓存对象。
     * @example
     * <listing version="3.0">
     * var area:Object = cache.getAreaByFrame(frame);
     * </listing>
     */
    public function getAreaByFrame(frame:int):Object {
        return _frameCache[frame];
    }

    /**
     * 记下这一帧的区域。同一帧后来的覆盖先前的。
     *
     * @param frame 帧号。
     * @param area 区域。可以是 <code>null</code>。
     * @example
     * <listing version="3.0">
     * cache.cacheAreaByFrame(frame, area);
     * </listing>
     */
    public function cacheAreaByFrame(frame:int, area:Object):void {
        _frameCache[frame] = area;
    }

    /**
     * 按元件当前外观取缓存。
     *
     * @param display 元件。为空时抛错。
     * @return 含 <code>name</code> 和 <code>area</code> 的对象。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var area:Object = cache.getAreaByDisplay(display);
     * </listing>
     */
    public function getAreaByDisplay(display:DisplayObject):Object {
        var cacheid:String = getDisplayCacheId(display);
        if (_idCache[cacheid]) {
            return _idCache[cacheid];
        }
        return null;
    }

    /**
     * 按元件当前外观记下区域，并返回这份缓存。
     *
     * <p><code>customParam</code> 里的同名字段会盖掉 <code>name</code> 和 <code>area</code>。</p>
     *
     * @param display 元件。为空时抛错。
     * @param area 区域。
     * @param customParam 额外字段。默认 <code>null</code>。
     * @return 刚写入的缓存对象。
     * @example
     * <listing version="3.0">
     * var cached:Object = cache.cacheAreaByDisplay(display, rect, null);
     * </listing>
     */
    public function cacheAreaByDisplay(display:DisplayObject, area:Rectangle, customParam:Object = null):Object {
        var cacheid:String = getDisplayCacheId(display);

        var displayName:String = display.name;

        var cacheObj:Object = {};

        cacheObj.name = displayName;
        cacheObj.area = area;

        if (customParam) {
            for (var i:String in customParam) {
                cacheObj[i] = customParam[i];
            }
        }

        _idCache[cacheid] = cacheObj;
        return cacheObj;
    }

    /** @private */
    private function getDisplayCacheId(d:DisplayObject):String {
        return d.name + '_' + d.x + ',' + d.y + ',' + d.width + ',' + d.height + ',' + d.rotation;
    }

}
}
