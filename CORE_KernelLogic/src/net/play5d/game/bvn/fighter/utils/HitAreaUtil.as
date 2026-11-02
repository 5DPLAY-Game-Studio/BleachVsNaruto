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

package net.play5d.game.bvn.fighter.utils {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import net.play5d.game.bvn.fighter.models.FighterHitModel;
import net.play5d.game.bvn.fighter.models.HitVO;

/**
 * 帧缓存攻击区域的扫描与收集、按名取判定包围盒，以及按朝向换算世界坐标。
 *
 * <p>区域来源、朝向、位置和矩形缓存由调用方提供。</p>
 *
 * @see #collectCurrentHits()
 * @see #findHitArea()
 * @see #getCheckHitRect()
 * @see #toWorldRect()
 */
public class HitAreaUtil {

    /**
     * 按帧区域填写 <code>HitVO.currentArea</code>，并写入复用的结果数组。
     *
     * @param areas 帧缓存区域。元素含 <code>hitVO</code> 与 <code>area</code>；空则返回 <code>null</code>。
     * @param hitsBuf 复用的结果数组。无有效区域时不改动。
     * @param placeRect 把局部矩形换到世界坐标。<code>function(area:Rectangle, cacheId:String):Rectangle</code>。
     * @return <code>hitsBuf</code>；<code>areas</code> 为空时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * return HitAreaUtil.collectCurrentHits(areas, _hitsBuf, getCurrentRect);
     * </listing>
     */
    public static function collectCurrentHits(areas:Array, hitsBuf:Array, placeRect:Function):Array {
        if (!areas || areas.length < 1) {
            return null;
        }

        hitsBuf.length = 0;

        for (var i:int = 0; i < areas.length; i++) {
            var dobj:Object = areas[i];
            var hitvo:HitVO = dobj.hitVO;
            if (!hitvo) {
                continue;
            }

            // 帧缓存是局部矩形，按当前朝向重算世界坐标
            hitvo.currentArea = placeRect(dobj.area, 'hit' + i);
            hitsBuf.push(hitvo);
        }

        return hitsBuf;
    }

    /**
     * 按朝向把局部矩形变到世界坐标，并按 <code>cacheId</code> 复用结果矩形。
     *
     * <p>朝向为负时，x 再减去矩形宽度，使翻转后的区域仍盖住原范围。</p>
     *
     * @param rect 局部矩形。
     * @param direct 朝向。<code>1</code> 向右，负值向左。
     * @param x 世界坐标 x。
     * @param y 世界坐标 y。
     * @param rectCache <code>cacheId</code> 非空时使用的矩形缓存；键为缓存 id。
     * @param cacheId 缓存键。为空时每次新建矩形。
     * @return 世界坐标矩形。
     * @example
     * <listing version="3.0">
     * var world:Rectangle = HitAreaUtil.toWorldRect(area, direct, x, y, rectCache, 'hit0');
     * </listing>
     */
    public static function toWorldRect(
            rect     :Rectangle,
            direct   :int,
            x        :Number,
            y        :Number,
            rectCache:Object = null,
            cacheId  :String = null
    ):Rectangle {
        var world:Rectangle;
        if (cacheId == null) {
            world = new Rectangle();
        }
        else if (rectCache[cacheId]) {
            world = rectCache[cacheId];
        }
        else {
            world              = new Rectangle();
            rectCache[cacheId] = world;
        }

        world.x = rect.x * direct + x;
        if (direct < 0) {
            world.x -= rect.width;
        }

        world.y      = rect.y + y;
        world.width  = rect.width;
        world.height = rect.height;

        return world;
    }

    /**
     * 按子对象名取局部包围盒，并写入 <code>McAreaCacher</code>。
     *
     * @param host 查找子对象的容器。
     * @param name 子对象名。
     * @param cache 判定包围盒缓存。
     * @param boundsTarget <code>getBounds</code> 的坐标空间。
     * @return 局部包围盒；没有该子对象时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var area:Rectangle = HitAreaUtil.getCheckHitRect(mc, 'hit1', cache, mc);
     * </listing>
     * @see McAreaCacher#getAreaByDisplay()
     */
    public static function getCheckHitRect(
            host        :DisplayObjectContainer,
            name        :String,
            cache       :McAreaCacher,
            boundsTarget:DisplayObject
    ):Rectangle {
        var child:DisplayObject = host.getChildByName(name);
        if (!child) {
            return null;
        }

        var cacheObj:Object = cache.getAreaByDisplay(child);
        if (cacheObj) {
            return cacheObj.area;
        }

        var rect:Rectangle = child.getBounds(boundsTarget);
        cache.cacheAreaByDisplay(child, rect);

        return rect;
    }

    /**
     * 扫描容器子节点，按名取 <code>HitVO</code>，并写入该帧的区域缓存。
     *
     * <p>本帧已经写过缓存时直接返回。没有任何命中子节点时写入 <code>null</code>，避免下一帧把「未命中」当成「尚未扫描」。</p>
     *
     * @param host 子节点容器。
     * @param frame 时间轴帧。
     * @param cache 帧区域缓存。为空时直接返回。
     * @param boundsTarget <code>getBounds</code> 的坐标空间。
     * @param hitModel 判定表。
     * @param byDisplayName 为 <code>true</code> 时用 <code>getHitVOByDisplayName</code>，否则用 <code>getHitVO</code>。
     * @example
     * <listing version="3.0">
     * HitAreaUtil.findHitArea(mc, mc.currentFrame, cache, mc, hitModel, false);
     * </listing>
     * @see FighterHitModel#getHitVO()
     * @see FighterHitModel#getHitVOByDisplayName()
     */
    public static function findHitArea(
            host         :DisplayObjectContainer,
            frame        :int,
            cache        :McAreaCacher,
            boundsTarget :DisplayObject,
            hitModel     :FighterHitModel,
            byDisplayName:Boolean
    ):void {
        if (!cache || cache.areaFrameDefined(frame) || cache.getAreaByFrame(frame) != null) {
            return;
        }

        var areaRects:Array = [];
        for (var i:int = 0; i < host.numChildren; i++) {
            var child:DisplayObject = host.getChildAt(i);
            var hitvo:HitVO;
            if (byDisplayName) {
                hitvo = hitModel.getHitVOByDisplayName(child.name);
            }
            else {
                hitvo = hitModel.getHitVO(child.name);
            }
            if (child == null || hitvo == null) {
                continue;
            }

            var areaCached:Object = cache.getAreaByDisplay(child);
            if (areaCached == null) {
                var areaRect:Rectangle = child.getBounds(boundsTarget);
                areaRects.push(cache.cacheAreaByDisplay(child, areaRect, {hitVO: hitvo}));
            }
            else {
                areaRects.push(areaCached);
            }
        }

        if (areaRects.length < 1) {
            areaRects = null;
        }

        cache.cacheAreaByFrame(frame, areaRects);
    }

}
}
