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
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.data.vos.BitmapDataCacheVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.kyo.utils.BitmapDataPool;

/**
 * 角色显示帧位图缓存（残影 / 发光滤镜）。
 *
 * <p>按角色 id、姿态键与效果参数缓存栅格化结果，避免同一姿势反复
 * <code>draw</code> / <code>applyFilter</code>。位图显示对象亦做轻量池化；
 * 栅格化缓冲走 <code>BitmapDataPool</code>。缓存满时仅淘汰未被
 * <code>retainShadow</code> / <code>retainFilter</code> 引用的条目。
 * 战斗结束应调用 <code>clear</code>。</p>
 *
 * @see net.play5d.kyo.utils.BitmapDataPool
 * @see net.play5d.game.bvn.views.effects.ShadowEffectView
 * @see net.play5d.game.bvn.views.effects.BitmapFilterView
 * @example
 * <listing version="3.0">
 * var key:String = DisplayFrameBitmapCache.buildShadowKey('ichigo', pose, 0, 0, 255);
 * var vo:BitmapDataCacheVO = DisplayFrameBitmapCache.I.getShadow(key);
 * </listing>
 */
public class DisplayFrameBitmapCache {

    private static var _i:DisplayFrameBitmapCache;

    /**
     * 单例。
     */
    public static function get I():DisplayFrameBitmapCache {
        _i ||= new DisplayFrameBitmapCache();

        return _i;
    }

    /** @private 残影缓存上限 */
    private static const MAX_SHADOW:int = 160;
    /** @private 滤镜缓存上限 */
    private static const MAX_FILTER:int = 80;
    /** @private Bitmap 池上限 */
    private static const MAX_BITMAP:int = 48;

    /** @private */
    private var _shadowMap:Object           = {};
    /** @private */
    private var _shadowKeys:Vector.<String> = new Vector.<String>();
    /** @private */
    private var _shadowRetain:Object        = {};
    /** @private */
    private var _filterMap:Object           = {};
    /** @private */
    private var _filterKeys:Vector.<String> = new Vector.<String>();
    /** @private */
    private var _filterRetain:Object        = {};
    /** @private */
    private var _bitmapPool:Vector.<Bitmap> = new Vector.<Bitmap>();
    /** @private */
    private var _tmpRect:Rectangle          = new Rectangle();
    /** @private */
    private var _tmpMatrix:Matrix           = new Matrix();
    /** @private */
    private var _tmpPoint:Point             = new Point();

    /**
     * 生成角色当前姿态键（含主时间轴与主要子 MC 帧）。
     *
     * @param fighter 角色。
     * @return 姿态键；无法解析时为空串。
     */
    public static function buildPoseKey(fighter:FighterMain):String {
        if (!fighter) {
            return '';
        }
        var fmc:FighterMC = fighter.getMC();
        if (!fmc) {
            return '';
        }
        return fmc.getPoseKey();
    }

    /**
     * 残影缓存键。
     *
     * @param fighterId 角色 id。
     * @param poseKey 姿态键。
     * @param r 红色偏移。
     * @param g 绿色偏移。
     * @param b 蓝色偏移。
     * @return 缓存键。
     */
    public static function buildShadowKey(
            fighterId:String, poseKey:String, r:int, g:int, b:int
    ):String {
        return 's|' + fighterId + '|' + poseKey + '|' + r + ',' + g + ',' + b;
    }

    /**
     * 滤镜缓存键。
     *
     * @param fighterId 角色 id。
     * @param poseKey 姿态键。
     * @param filter 滤镜。
     * @param filterOffset 绘制扩展。
     * @return 缓存键。
     */
    public static function buildFilterKey(
            fighterId:String, poseKey:String, filter:BitmapFilter, filterOffset:Point
    ):String {
        var ox:int = filterOffset ? int(filterOffset.x) : 0;
        var oy:int = filterOffset ? int(filterOffset.y) : 0;
        return 'f|' + fighterId + '|' + poseKey + '|' + filterHash(filter) + '|' + ox + ',' + oy;
    }

    /**
     * 读取残影缓存。
     *
     * @param key 缓存键。
     * @return 命中时的 VO，否则 <code>null</code>。
     */
    public function getShadow(key:String):BitmapDataCacheVO {
        if (!key) {
            return null;
        }
        return _shadowMap[key] as BitmapDataCacheVO;
    }

    /**
     * 写入残影缓存。
     *
     * @param key 缓存键。
     * @param vo 位图与偏移。
     * @return 已由缓存持有时为 <code>true</code>；无法腾出空间时为 <code>false</code>。
     */
    public function putShadow(key:String, vo:BitmapDataCacheVO):Boolean {
        if (!key || !vo || !vo.bitmapData) {
            return false;
        }
        return putLru(_shadowMap, _shadowKeys, _shadowRetain, key, vo, MAX_SHADOW, true);
    }

    /**
     * 增加残影缓存引用（显示中禁止淘汰）。
     *
     * @param key 缓存键。
     */
    public function retainShadow(key:String):void {
        retainKey(_shadowRetain, key);
    }

    /**
     * 减少残影缓存引用。
     *
     * @param key 缓存键。
     */
    public function releaseShadow(key:String):void {
        releaseKey(_shadowRetain, key);
    }

    /**
     * 读取滤镜结果缓存。
     *
     * @param key 缓存键。
     * @return 命中时的位图，否则 <code>null</code>。
     */
    public function getFilter(key:String):BitmapData {
        if (!key) {
            return null;
        }
        return _filterMap[key] as BitmapData;
    }

    /**
     * 写入滤镜结果缓存。
     *
     * @param key 缓存键。
     * @param bd 滤镜后位图。
     * @return 已由缓存持有时为 <code>true</code>；无法腾出空间时为 <code>false</code>。
     */
    public function putFilter(key:String, bd:BitmapData):Boolean {
        if (!key || !bd) {
            return false;
        }
        return putLru(_filterMap, _filterKeys, _filterRetain, key, bd, MAX_FILTER, false);
    }

    /**
     * 增加滤镜缓存引用（显示中禁止淘汰）。
     *
     * @param key 缓存键。
     */
    public function retainFilter(key:String):void {
        retainKey(_filterRetain, key);
    }

    /**
     * 减少滤镜缓存引用。
     *
     * @param key 缓存键。
     */
    public function releaseFilter(key:String):void {
        releaseKey(_filterRetain, key);
    }

    /**
     * 将显示对象绘制为残影位图并写入缓存。
     *
     * @param target 目标显示对象。
     * @param key 缓存键；空则只绘制不缓存。
     * @param colorTransform 颜色变换，可为 <code>null</code>。
     * @return 含位图与偏移的 VO；失败为 <code>null</code>。
     */
    public function drawShadow(
            target:DisplayObject, key:String, colorTransform:ColorTransform = null
    ):BitmapDataCacheVO {
        if (key) {
            var hit:BitmapDataCacheVO = getShadow(key);
            if (hit) {
                return hit;
            }
        }
        if (!target || target.width < 1 || target.height < 1) {
            return null;
        }
        var bds:Rectangle = target.getBounds(target);
        var w:int         = Math.ceil(target.width);
        var h:int         = Math.ceil(target.height);
        if (w < 1 || h < 1) {
            return null;
        }

        var bd:BitmapData = BitmapDataPool.I.acquire(w, h, true, 0);
        if (!bd) {
            return null;
        }
        _tmpMatrix.identity();
        _tmpMatrix.tx = -bds.x;
        _tmpMatrix.ty = -bds.y;
        bd.draw(target, _tmpMatrix, colorTransform);

        var vo:BitmapDataCacheVO = new BitmapDataCacheVO();
        vo.bitmapData            = bd;
        vo.offsetX               = bds.x;
        vo.offsetY               = bds.y;
        if (key) {
            putShadow(key, vo);
            var cachedVo:BitmapDataCacheVO = getShadow(key);
            if (cachedVo) {
                return cachedVo;
            }
        }
        return vo;
    }

    /**
     * 判断残影 VO 是否仍由缓存持有。
     *
     * @param key 缓存键。
     * @param vo 位图 VO。
     * @return 缓存持有时为 <code>true</code>。
     */
    public function isShadowCached(key:String, vo:BitmapDataCacheVO):Boolean {
        return key != null && key.length > 0 && vo != null && getShadow(key) == vo;
    }

    /**
     * 判断滤镜位图是否仍由缓存持有。
     *
     * @param key 缓存键。
     * @param bd 位图。
     * @return 缓存持有时为 <code>true</code>。
     */
    public function isFilterCached(key:String, bd:BitmapData):Boolean {
        return key != null && key.length > 0 && bd != null && getFilter(key) == bd;
    }

    /**
     * 绘制带滤镜的位图；中间与输出缓冲走 <code>BitmapDataPool</code>。
     *
     * @param target 目标显示对象。
     * @param filter 滤镜。
     * @param filterOffset 绘制扩展。
     * @param key 缓存键；空则只绘制不缓存。
     * @return 滤镜后位图；失败为 <code>null</code>。
     */
    public function drawFilter(
            target:DisplayObject, filter:BitmapFilter, filterOffset:Point = null, key:String = null
    ):BitmapData {
        if (key) {
            var hit:BitmapData = getFilter(key);
            if (hit) {
                return hit;
            }
        }
        if (!target || !filter || target.width < 1 || target.height < 1) {
            return null;
        }
        var w:int = Math.ceil(target.width);
        var h:int = Math.ceil(target.height);
        if (w < 1 || h < 1) {
            return null;
        }

        var src:BitmapData = BitmapDataPool.I.acquire(w, h, true, 0);
        if (!src) {
            return null;
        }
        var bds:Rectangle = target.getBounds(target);
        _tmpMatrix.identity();
        _tmpMatrix.tx = -bds.x;
        _tmpMatrix.ty = -bds.y;
        src.draw(target, _tmpMatrix);

        _tmpRect.setTo(0, 0, w, h);
        if (filterOffset) {
            _tmpRect.x -= filterOffset.x;
            _tmpRect.y -= filterOffset.y;
            _tmpRect.width += filterOffset.x * 2;
            _tmpRect.height += filterOffset.y * 2;
        }

        var fw:int = Math.ceil(_tmpRect.width);
        var fh:int = Math.ceil(_tmpRect.height);
        if (fw < 1 || fh < 1) {
            BitmapDataPool.I.release(src);
            return null;
        }

        var dst:BitmapData = BitmapDataPool.I.acquire(fw, fh, true, 0);
        if (!dst) {
            BitmapDataPool.I.release(src);
            return null;
        }
        _tmpPoint.setTo(0, 0);
        dst.applyFilter(src, _tmpRect, _tmpPoint, filter);
        BitmapDataPool.I.release(src);

        if (key) {
            putFilter(key, dst);
            var cachedBd:BitmapData = getFilter(key);
            if (cachedBd) {
                return cachedBd;
            }
        }
        return dst;
    }

    /**
     * 从池取得 <code>Bitmap</code> 并挂上位图数据。
     *
     * @param bd 位图数据（通常来自缓存，调用方勿 dispose）。
     * @return 位图显示对象。
     */
    public function borrowBitmap(bd:BitmapData):Bitmap {
        var bp:Bitmap;
        if (_bitmapPool.length > 0) {
            bp = _bitmapPool.pop();
        }
        else {
            bp = new Bitmap(null, 'auto', false);
        }
        bp.bitmapData = bd;
        bp.alpha      = 1;
        bp.rotation   = 0;
        bp.scaleX     = 1;
        bp.scaleY     = 1;
        bp.x          = 0;
        bp.y          = 0;
        return bp;
    }

    /**
     * 归还 <code>Bitmap</code>；不 dispose 其 <code>bitmapData</code>。
     *
     * @param bp 由 <code>borrowBitmap</code> 取得的实例。
     */
    public function releaseBitmap(bp:Bitmap):void {
        if (!bp) {
            return;
        }
        bp.bitmapData = null;
        if (_bitmapPool.length < MAX_BITMAP) {
            _bitmapPool.push(bp);
        }
    }

    /**
     * 清空帧缓存与 Bitmap 池，并清空 <code>BitmapDataPool</code>。
     */
    public function clear():void {
        disposeShadowAll();
        disposeFilterAll();
        _shadowRetain = {};
        _filterRetain = {};
        _bitmapPool.length = 0;
        BitmapDataPool.I.clear();
    }

    /** @private */
    private static function filterHash(filter:BitmapFilter):String {
        if (filter is GlowFilter) {
            var gf:GlowFilter = filter as GlowFilter;
            return 'g' + gf.color + '_' + gf.alpha + '_' + gf.blurX + '_' + gf.blurY + '_' +
                   gf.strength + '_' + (gf.inner ? 1 : 0) + '_' + (gf.knockout ? 1 : 0) + '_' +
                   gf.quality;
        }
        return filter ? getQualifiedClassName(filter) : 'null';
    }

    /**
     * @private
     * 写入缓存。已存在则保留旧条目；已满则淘汰无引用条目。
     * @return 是否由缓存持有（调用方据此决定销毁时是否归还池）。
     */
    private function putLru(
            map:Object, keys:Vector.<String>, retain:Object, key:String, value:Object, max:int,
            isShadowVO:Boolean
    ):Boolean {
        if (map[key]) {
            touchKey(keys, key);
            if (value && value != map[key]) {
                releaseCachedValue(value, isShadowVO);
            }
            return true;
        }
        while (keys.length >= max) {
            if (!evictOne(map, keys, retain, isShadowVO)) {
                return false;
            }
        }
        map[key] = value;
        keys.push(key);
        return true;
    }

    /** @private */
    private function evictOne(
            map:Object, keys:Vector.<String>, retain:Object, isShadowVO:Boolean
    ):Boolean {
        for (var i:int = 0; i < keys.length; i++) {
            var ek:String = keys[i];
            if (int(retain[ek]) > 0) {
                continue;
            }
            keys.splice(i, 1);
            var old:Object = map[ek];
            delete map[ek];
            releaseCachedValue(old, isShadowVO);
            return true;
        }
        return false;
    }

    /** @private */
    private function releaseCachedValue(value:Object, isShadowVO:Boolean):void {
        if (isShadowVO) {
            var vo:BitmapDataCacheVO = value as BitmapDataCacheVO;
            if (vo && vo.bitmapData) {
                BitmapDataPool.I.release(vo.bitmapData);
                vo.bitmapData = null;
            }
        }
        else {
            var bd:BitmapData = value as BitmapData;
            if (bd) {
                BitmapDataPool.I.release(bd);
            }
        }
    }

    /** @private */
    private static function retainKey(retain:Object, key:String):void {
        if (!key) {
            return;
        }
        retain[key] = int(retain[key]) + 1;
    }

    /** @private */
    private static function releaseKey(retain:Object, key:String):void {
        if (!key) {
            return;
        }
        var n:int = int(retain[key]) - 1;
        if (n <= 0) {
            delete retain[key];
        }
        else {
            retain[key] = n;
        }
    }

    /** @private */
    private static function touchKey(keys:Vector.<String>, key:String):void {
        var idx:int = keys.indexOf(key);
        if (idx != -1) {
            keys.splice(idx, 1);
            keys.push(key);
        }
    }

    /** @private */
    private function disposeShadowAll():void {
        for each(var vo:BitmapDataCacheVO in _shadowMap) {
            if (vo && vo.bitmapData) {
                try {
                    vo.bitmapData.dispose();
                }
                catch (e:Error) {
                }
            }
        }
        _shadowMap         = {};
        _shadowKeys.length = 0;
    }

    /** @private */
    private function disposeFilterAll():void {
        for each(var bd:BitmapData in _filterMap) {
            if (bd) {
                try {
                    bd.dispose();
                }
                catch (e:Error) {
                }
            }
        }
        _filterMap         = {};
        _filterKeys.length = 0;
    }

}
}
