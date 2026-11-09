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

package net.play5d.game.bvn.views.effects {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import net.play5d.game.bvn.ctrler.effect.BitmapDataCacheVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.ctrler.effect.DisplayFrameBitmapCache;
import net.play5d.kyo.utils.BitmapDataPool;

/**
 * 残影效果视图。
 *
 * <p>按间隔抓取目标显示对象快照并淡出。角色残影优先命中
 * <code>DisplayFrameBitmapCache</code>，<code>Bitmap</code> 显示对象走池化。</p>
 *
 * @see DisplayFrameBitmapCache
 */
public class ShadowEffectView {

    /**
     * 按目标抓残影并淡出。三色偏移默认都是 0，全是 0 时不染色。
     *
     * <p>取样计数从 0 开始，间隔是 1，要等计数先自增再大于间隔才抓一张，所以第 3 次 <code>render</code> 才出现第一张，之后每 3 次一张。新残影从 0.8 开始，同一帧先减 0.1。同一帧里连续两张都淡完时，后一张要等下一帧。容器还没赋值就取样会抛错。<code>stopShadow</code> 之后不再取样，残影清空的下一次渲染才调用 <code>onRemove</code>。</p>
     *
     * @param target 残影源显示对象。
     * @param r 红色偏移。默认 0。
     * @param g 绿色偏移。默认 0。
     * @param b 蓝色偏移。默认 0。
     * @param owner 可选所属精灵，用于帧缓存键。默认 null。通常是角色。
     */
    public function ShadowEffectView(
            target:DisplayObject, r:int = 0, g:int = 0, b:int = 0, owner:BaseGameSprite = null
    ) {
        this.target = target;
        this.r      = r;
        this.g      = g;
        this.b      = b;
        this.owner  = owner;

        _addBpFrame = 0;
    }
    /**
     * 残影源。销毁后是 null。
     */
    public var target:DisplayObject;
    /**
     * 红色偏移。全是 0 时不染色。
     *
     * @default 0
     */
    public var r:int                           = 0;
    /**
     * 绿色偏移。
     *
     * @default 0
     */
    public var g:int                           = 0;
    /**
     * 蓝色偏移。
     *
     * @default 0
     */
    public var b:int                           = 0;
    /**
     * 用来生成缓存键的所属精灵。不是角色时键为空。
     *
     * @default null
     */
    public var owner:BaseGameSprite;
    /**
     * 残影加到这个容器的最底层。取样前必须赋值。
     *
     * @default null
     */
    public var container:Sprite;
    /**
     * 为 true 时不再抓新残影。
     *
     * @default false
     */
    public var stopShadow:Boolean;
    /**
     * 残影已经停并且清空后的下一次渲染调用。null 时不调用。
     *
     * @default null
     */
    public var onRemove:Function;
    private var _bps:Vector.<Bitmap>           = new Vector.<Bitmap>();
    /** @private Bitmap -&gt; 缓存键（String）或 false（未入缓存） */
    private var _bpCached:Dictionary           = new Dictionary();
    private var _alphaLoss:Number              = 0.1;
    private var _alphaStart:Number             = 0.8;
    private var _addBpGap:int                  = 1;
    private var _addBpFrame:int                = 0;
    /** @private 复用颜色变换，避免采样时反复分配 */
    private var _colorTransform:ColorTransform = new ColorTransform();

    /**
     * 销毁残影并释放显示对象。
     */
    public function destroy():void {
        target = null;
        owner  = null;
        if (_bps) {
            for (var i:int; i < _bps.length; i++) {
                var bp:Bitmap = _bps[i];
                try {
                    container.removeChild(bp);
                }
                catch (error:Error) {
                }
                freeShadowBitmap(bp);
            }
        }
        _bps      = null;
        _bpCached = null;
    }

    /**
     * 取样或淡出。已经销毁时抛错。停掉之后没有残影时通知移除。
     *
     * @throws TypeError 已经销毁，或容器、目标缺失时。
     * @example
     * <listing version="3.0">
     * shadow.render();
     * </listing>
     */
    public function render():void {

        if (stopShadow) {
            if (_bps.length <= 0) {
                removeSelf();
            }
        }
        else {
            if (_addBpFrame++ > _addBpGap) {
                addShadowBp();
                _addBpFrame = 0;
            }
        }

        for (var i:int; i < _bps.length; i++) {
            var bp:Bitmap = _bps[i];
            bp.alpha -= _alphaLoss;
            if (bp.alpha <= 0) {
                removeBitmap(bp);
            }
        }

    }

    private function addShadowBp():void {
        var colorTransform:ColorTransform;
        if (r != 0 || g != 0 || b != 0) {
            _colorTransform.redOffset   = r;
            _colorTransform.greenOffset = g;
            _colorTransform.blueOffset  = b;
            colorTransform              = _colorTransform;
        }

        var cache:DisplayFrameBitmapCache = DisplayFrameBitmapCache.I;
        var key:String                    = buildCacheKey();
        var vo:BitmapDataCacheVO          = cache.drawShadow(target, key, colorTransform);
        if (vo == null || vo.bitmapData == null) {
            return;
        }

        var bds:Rectangle = target.getBounds(target);
        var bp:Bitmap     = cache.borrowBitmap(vo.bitmapData);
        bp.alpha          = _alphaStart;
        bp.x              = target.x + bds.x * target.scaleX;
        bp.y              = target.y + bds.y;
        bp.scaleX         = target.scaleX;
        bp.scaleY         = target.scaleY;
        container.addChildAt(bp, 0);
        _bps.push(bp);
        if (cache.isShadowCached(key, vo)) {
            cache.retainShadow(key);
            _bpCached[bp] = key;
        }
        else {
            _bpCached[bp] = false;
        }
    }

    private function buildCacheKey():String {
        if (!(owner is FighterMain)) {
            return null;
        }
        var f:FighterMain = owner as FighterMain;
        if (!f.data || !f.data.id) {
            return null;
        }
        var pose:String = DisplayFrameBitmapCache.buildPoseKey(f);
        if (!pose) {
            return null;
        }
        return DisplayFrameBitmapCache.buildShadowKey(f.data.id, pose, r, g, b);
    }

    private function removeBitmap(bp:Bitmap):void {
        var id:int = _bps.indexOf(bp);
        if (id != -1) {
            _bps.splice(id, 1);
        }

        try {
            container.removeChild(bp);
        }
        catch (e:Error) {
        }

        freeShadowBitmap(bp);
    }

    private function freeShadowBitmap(bp:Bitmap):void {
        if (!bp) {
            return;
        }
        var cacheKey:*    = _bpCached ? _bpCached[bp] : null;
        var bd:BitmapData = bp.bitmapData;
        DisplayFrameBitmapCache.I.releaseBitmap(bp);
        if (cacheKey is String) {
            DisplayFrameBitmapCache.I.releaseShadow(cacheKey as String);
        }
        else if (bd) {
            BitmapDataPool.I.release(bd);
        }
        if (_bpCached) {
            delete _bpCached[bp];
        }
    }

    private function removeSelf():void {
        if (onRemove != null) {
            onRemove(this);
        }
    }

}
}
