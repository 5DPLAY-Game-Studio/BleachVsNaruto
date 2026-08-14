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

import net.play5d.game.bvn.data.vos.BitmapDataCacheVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.utils.DisplayFrameBitmapCache;
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
     * @param target 残影源显示对象。
     * @param r 红色偏移。
     * @param g 绿色偏移。
     * @param b 蓝色偏移。
     * @param owner 可选所属精灵，用于帧缓存键（通常为 <code>FighterMain</code>）。
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
    public var target:DisplayObject;
    public var r:int = 0;
    public var g:int = 0;
    public var b:int = 0;
    public var owner:BaseGameSprite;
    public var container:Sprite;
    public var stopShadow:Boolean;
    public var onRemove:Function;
    private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
    /** @private Bitmap -&gt; 缓存键（String）或 false（未入缓存） */
    private var _bpCached:Dictionary = new Dictionary();
    private var _alphaLoss:Number    = 0.1;
    private var _alphaStart:Number   = 0.8;
    private var _addBpGap:int        = 1;
    private var _addBpFrame:int      = 0;
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
     * 每动画帧推进：采样新残影并淡出旧残影。
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
        var ct:ColorTransform;
        if (r != 0 || g != 0 || b != 0) {
            _colorTransform.redOffset   = r;
            _colorTransform.greenOffset = g;
            _colorTransform.blueOffset  = b;
            ct                          = _colorTransform;
        }

        var cache:DisplayFrameBitmapCache = DisplayFrameBitmapCache.I;
        var key:String                    = buildCacheKey();
        var vo:BitmapDataCacheVO          = cache.drawShadow(target, key, ct);
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
