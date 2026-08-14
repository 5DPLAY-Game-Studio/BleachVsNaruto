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

package net.play5d.game.bvn.map {
import flash.geom.Matrix;

/**
 * 对局地图层位图缓存工具。
 *
 * <p>在构建对局后为地图主层启用 <code>cacheAsBitmapMatrix</code> /
 * <code>cacheAsBitmap</code>，供各壳 <code>afterBuildGame</code> 复用。</p>
 *
 * @see MapMain
 */
public class MapLayerCacheUtil {

    /**
     * 为地图各层启用位图缓存。
     *
     * @param map 当前对局地图；为 null 时忽略。
     *
     * @example
     * <listing version="3.0">
     * MapLayerCacheUtil.enableBitmapCache(GameCtrl.I.gameState.getMap());
     * </listing>
     */
    public static function enableBitmapCache(map:MapMain):void {
        if (!map) {
            return;
        }
        if (map.mapLayer) {
            map.mapLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.frontLayer) {
            map.frontLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.frontFixLayer) {
            map.frontFixLayer.cacheAsBitmapMatrix = new Matrix();
        }
        if (map.bgLayer) {
            map.bgLayer.cacheAsBitmap = true;
        }
    }
}
}
