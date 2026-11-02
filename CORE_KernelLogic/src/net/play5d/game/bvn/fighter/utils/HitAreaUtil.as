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
import flash.geom.Rectangle;

import net.play5d.game.bvn.fighter.models.HitVO;

/**
 * 帧缓存攻击区域的收集，以及按朝向换算世界坐标。
 *
 * <p>区域来源、朝向、位置和矩形缓存由调用方提供。</p>
 *
 * @see #collectCurrentHits()
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

}
}
