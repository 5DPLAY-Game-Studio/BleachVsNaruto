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

package net.play5d.game.bvn.data.vos {
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.effect.BitmapDataCacheVO;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 一份特效的类名、震动、定格和帧缓存。
 *
 * <p>帧缓存按 <code>className</code> 共用。循环停在 <code>currentFrame &lt; totalFrames</code>，所以最后一帧不会画进去。只有 1 帧时缓存是空数组。
 * 宽或高小于 1 的帧记成 <code>null</code>。连续两帧画面和偏移都一样时复用上一帧。</p>
 *
 * @see EffectModel
 */
public class EffectVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 记下类名，并把 <code>param</code> 里的同名字段写上来。
     *
     * <p><code>param</code> 为空时不写字段。</p>
     *
     * @param className 特效类名。没有类名、又有自定义类时，缓存改用自定义类。
     * @param param 要写上的字段。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var fx:EffectVO = new EffectVO('XG_jump', {sound: 'snd_jump'});
     * </listing>
     */
    public function EffectVO(className:String, param:Object = null) {
        this.className = className;
        if (param) {
            KyoUtils.setValueByObject(this, param);
        }
    }

    /**
     * 特效类名。
     *
     * @default null
     */
    public var className:String;
    /**
     * 闪光。常用字段是 <code>color</code> 和 <code>alpha</code>。
     *
     * @default null
     */
    public var shine:Object;
    /**
     * 震动。有 <code>pow</code> 时，播放处会改写 <code>y</code>。
     *
     * @default null
     */
    public var shake:Object;
    /**
     * 定格毫秒。
     *
     * @default 0
     */
    public var freeze:int;
    /**
     * 音效类名。
     *
     * @default null
     */
    public var sound:String;
    /**
     * 是否随机旋转。
     *
     * @default false
     */
    public var randRotate:Boolean;
    /**
     * 是否跟着角色朝向。
     *
     * @default false
     */
    public var followDirect:Boolean;
    /**
     * 慢放。常用字段是 <code>rate</code> 和 <code>time</code>。
     *
     * @default null
     */
    public var slowDown:Object;
    /**
     * 混合模式。
     *
     * @default normal
     */
    public var blendMode:String   = BlendMode.NORMAL;
    /**
     * 逐帧位图。缓存前为 <code>null</code>。
     *
     * @default null
     */
    public var bitmapDataCache:Vector.<BitmapDataCacheVO>;
    /**
     * 帧号到帧标签。缓存前为 <code>null</code>。
     *
     * @default null
     */
    public var frameLabelCache:Object;
    /**
     * 跟着目标再播的特殊特效 id。
     *
     * @default null
     */
    public var specialEffectId:String;
    /**
     * 目标颜色偏移。
     *
     * @default null
     */
    public var targetColorOffset:Array;
    /**
     * 是否特殊特效。
     *
     * @default false
     */
    public var isSpecial:Boolean  = false;
    /**
     * 是否 buff 特效。
     *
     * @default false
     */
    public var isBuff:Boolean     = false;
    /**
     * 是否钢体受击特效。
     *
     * @default false
     */
    public var isSteelHit:Boolean = false;

    /**
     * 自定义影片类。没有 <code>className</code> 时缓存用它。
     *
     * @default null
     */
    public var customMcCls:Class;
    /**
     * 自定义声音类。
     *
     * @default null
     */
    public var customSndCls:Class;
    /** @private 相同 className 共用的帧位图与帧标签 */
    private static var _sharedFrameCache:Object;

    /**
     * 把元件逐帧画成位图。
     *
     * <p>相同 <code>className</code> 共用一份帧数据。连续相同的静帧复用上一帧，并释放本次位图。</p>
     *
     * @example
     * <listing version="3.0">
     * effect.cacheBitmapData();
     * </listing>
     */
    public function cacheBitmapData():void {
        if (useSharedFrames()) {
            return;
        }

        bitmapDataCache = new Vector.<BitmapDataCacheVO>();
        frameLabelCache = {};

        var mc:MovieClip;
        if (!className && customMcCls) {
            mc = new customMcCls() as MovieClip;
        }
        else {
            mc = AssetManager.I.getEffect(className);
        }

        mc.gotoAndStop(1);
        var bounds:Rectangle;
        var cache:BitmapDataCacheVO;

        while (mc.currentFrame < mc.totalFrames) {

            var frameLabel:String = mc.currentFrameLabel;
            if (frameLabel) {
                frameLabelCache[mc.currentFrame] = frameLabel;
            }

            if (mc.width < 1 || mc.height < 1) {
                bitmapDataCache.push(null);
                mc.nextFrame();
                continue;
            }

            var bd:BitmapData = new BitmapData(mc.width, mc.height, true, 0);
            bounds            = mc.getBounds(mc);
            bd.draw(mc, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));

            var offsetX:Number = bounds.x;
            var offsetY:Number = bounds.y;

            if (cache && cache.offsetX == offsetX && cache.offsetY == offsetY) {
                var compared:Object = cache.bitmapData.compare(bd);
                var diff:BitmapData = compared as BitmapData;
                if (diff) {
                    diff.dispose();
                }
                else if (compared == 0) {
                    bd.dispose();
                    bitmapDataCache.push(cache);
                    mc.nextFrame();
                    continue;
                }
            }

            cache            = new BitmapDataCacheVO();
            cache.bitmapData = bd;
            cache.offsetX    = offsetX;
            cache.offsetY    = offsetY;
            bitmapDataCache.push(cache);

            mc.nextFrame();
        }

        mc     = null;
        bounds = null;
        cache  = null;

        storeSharedFrames();
    }

    /** @private */
    private function useSharedFrames():Boolean {
        if (!className || !_sharedFrameCache) {
            return false;
        }
        var shared:Object = _sharedFrameCache[className];
        if (!shared) {
            return false;
        }
        bitmapDataCache = shared.frames;
        frameLabelCache = shared.labels;

        return true;
    }

    /** @private */
    private function storeSharedFrames():void {
        if (!className) {
            return;
        }
        _sharedFrameCache ||= {};
        _sharedFrameCache[className] = {
            frames: bitmapDataCache,
            labels: frameLabelCache
        };
    }

}
}
