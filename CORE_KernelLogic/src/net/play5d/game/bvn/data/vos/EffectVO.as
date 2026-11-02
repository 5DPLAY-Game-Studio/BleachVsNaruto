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
 * 效果值对象
 */
public class EffectVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    public function EffectVO(className:String, param:Object = null) {
        this.className = className;
        if (param) {
            KyoUtils.setValueByObject(this, param);
        }
    }

    public var className:String;
    public var shine:Object;//闪光{color,alpha}
    public var shake:Object;//震动{x,y|pow,time[毫秒，可选]} , 当设置pow时，x,y无效，根据hitvo.hitx,hity进行震动
    public var freeze:int;//暂停时间（毫秒）
    public var sound:String; //声音(暂时不用)
    public var randRotate:Boolean; //随机角度旋转
    public var followDirect:Boolean; //跟随角色朝向
    public var slowDown:Object; //慢放效果{rate[慢放倍数],time[慢放时间（毫秒）]}
    public var blendMode:String   = BlendMode.NORMAL;
    public var bitmapDataCache:Vector.<BitmapDataCacheVO>;
    public var frameLabelCache:Object;
    public var specialEffectId:String;
    public var targetColorOffset:Array;
    public var isSpecial:Boolean  = false;
    public var isBuff:Boolean     = false;
    public var isSteelHit:Boolean = false;

    // 自定义特效元件链接
    public var customMcCls:Class;
    // 自定义特效声音链接
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
