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
import net.play5d.game.bvn.fighter.models.HitVO;

/**
 * 把帧缓存里的攻击区域收成当前命中列表。
 *
 * <p>区域来源和世界坐标换算由调用方提供。坐标换算沿用各自的 <code>getCurrentRect</code>。</p>
 *
 * @see #collectCurrentHits()
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

}
}
