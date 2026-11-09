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
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.ctrler.effect.DisplayFrameBitmapCache;
import net.play5d.kyo.utils.BitmapDataPool;

/**
 * 角色发光等持续滤镜的位图覆盖层。
 *
 * <p>仅在角色动画帧变化时重绘；结果优先写入
 * <code>DisplayFrameBitmapCache</code>，中间缓冲走 <code>BitmapDataPool</code>。</p>
 *
 * @see DisplayFrameBitmapCache
 */
public class BitmapFilterView implements IGameSprite {

    /**
     * 盖住目标的滤镜位图。目标为 null 时抛错。偏移先存下来，为 null 时渲染读坐标会抛错。
     *
     * <p>角色的动画帧计数从 0 记起。第一次渲染时如果计数仍是 0，这一帧不画，接着读边界会抛错。<code>update</code> 会把帧计数改成 -1，下一次就会画。</p>
     *
     * @param target 被覆盖的精灵。
     * @param filter 滤镜。
     * @param filterOffset 绘制和摆放用的偏移。默认 null。
     * @throws TypeError 目标为 null 时。
     */
    public function BitmapFilterView(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null) {
        _bitmap     = new Bitmap(null, 'auto', false);
        this.target = target;

        if (target is FighterMain) {
            _targetFighter = target as FighterMain;
        }

        _targetDisplay = target.getDisplay();
        _filter        = filter;
        _filterOffset  = filterOffset;
    }
    /**
     * 被覆盖的精灵。<code>destroy(true)</code> 之后是 null。
     */
    public var target:BaseGameSprite;
    private var _bitmap:Bitmap;
    private var _filter:BitmapFilter;
    private var _filterOffset:Point;
    private var _isDestroyed:Boolean;
    private var _bitmapFrame:int;
    private var _targetDisplay:DisplayObject;
    private var _targetBounds:Rectangle;
    private var _targetFighter:FighterMain;
    private var _isActive:Boolean;
    /** @private 当前 bitmapData 是否由帧缓存持有 */
    private var _bdCached:Boolean;
    /** @private 最近一次绘制使用的缓存键 */
    private var _cacheKey:String;

    /**
     * 颜色变换。
     *
     * @return 固定 null。
     */
    public function get colorTransform():ColorTransform {
        return null;
    }

    /** @private */
    public function set colorTransform(colorTransform:ColorTransform):void {
    }

    /**
     * 目标的方向。目标已清空时抛错。设置方向没有效果，渲染仍读目标自己的方向。
     *
     * @return 目标方向。0 也走朝左的摆法。
     * @throws TypeError 目标为 null 时。
     */
    public function get direct():int {
        return target.direct;
    }

    /** @private */
    public function set direct(value:int):void {

    }

    /**
     * 位图横坐标。每次渲染都会按目标和偏移重写。
     *
     * @return 当前横坐标。
     */
    public function get x():Number {
        return _bitmap.x;
    }

    /** @private */
    public function set x(v:Number):void {
        _bitmap.x = v;
    }

    /**
     * 位图纵坐标。每次渲染都会按目标和偏移重写。
     *
     * @return 当前纵坐标。
     */
    public function get y():Number {
        return _bitmap.y;
    }

    /** @private */
    public function set y(v:Number):void {
        _bitmap.y = v;
    }

    /**
     * 队伍。
     *
     * @return 固定 null。
     */
    public function get team():TeamVO {
        return null;
    }

    /** @private */
    public function set team(v:TeamVO):void {

    }

    /**
     * 是否标成激活。默认 false。渲染不看这个值。
     *
     * @return 激活标记。
     * @default false
     * @example
     * <listing version="3.0">
     * var on:Boolean = view.getActive();
     * </listing>
     */
    public function getActive():Boolean {
        return _isActive;
    }

    /**
     * 只改激活标记。
     *
     * @param v 是否激活。
     * @example
     * <listing version="3.0">
     * view.setActive(true);
     * </listing>
     */
    public function setActive(v:Boolean):void {
        _isActive = v;
    }

    /**
     * 空实现。
     *
     * @param v 音量。不使用。
     */
    public function setVolume(v:Number):void {
    }

    /**
     * 换滤镜和偏移，并让下一帧重画。偏移为 null 时，下次渲染抛错。
     *
     * @param filter 滤镜。
     * @param filterOffset 偏移。默认 null。
     * @example
     * <listing version="3.0">
     * view.update(filter, offset);
     * </listing>
     */
    public function update(filter:BitmapFilter, filterOffset:Point = null):void {
        _filter       = filter;
        _filterOffset = filterOffset;
        _bitmapFrame  = -1;
    }

    /**
     * 空实现。
     *
     * @example
     * <listing version="3.0">
     * view.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
    }

    /**
     * 重画并跟上目标。没有目标、显示对象已空，或已经销毁时直接返回。偏移或边界还没有时抛错。
     *
     * @throws TypeError 偏移或边界缺失时。
     * @example
     * <listing version="3.0">
     * view.render();
     * </listing>
     */
    public function render():void {
        if (!target || !_targetDisplay) {
            return;
        }
        if (_isDestroyed) {
            return;
        }
        renderBitmapData();

        _bitmap.scaleX = _targetDisplay.scaleX;
        _bitmap.scaleY = _targetDisplay.scaleY;

        if (target.direct > 0) {
            _bitmap.x = _targetDisplay.x - _filterOffset.x + _targetBounds.x;
        }
        else {
            _bitmap.x = _targetDisplay.x + _filterOffset.x - _targetBounds.x;
        }

        _bitmap.y = _targetDisplay.y - _filterOffset.y + _targetBounds.y;
    }

    /**
     * 是否已按释放销毁。<code>destroy(false)</code> 不会把它变成 true。
     *
     * @return 已销毁时为 true。
     * @example
     * <listing version="3.0">
     * var gone:Boolean = view.isDestroyed();
     * </listing>
     */
    public function isDestroyed():Boolean {
        return _isDestroyed;
    }

    /**
     * 滤镜位图。销毁后这张位图还在，只是像素被清掉。
     *
     * @return 位图。
     * @example
     * <listing version="3.0">
     * var viewBmp:DisplayObject = view.getDisplay();
     * </listing>
     */
    public function getDisplay():DisplayObject {
        return _bitmap;
    }

    /**
     * 空实现。
     *
     * @param hitvo 攻击数据。不使用。
     * @param target 被打中的对象。不使用。
     */
    public function hit(hitvo:HitVO, target:IGameSprite):void {

    }

    /**
     * 空实现。
     *
     * @param hitvo 攻击数据。不使用。
     * @param hitRect 攻击范围。默认 null。
     */
    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {

    }

    /**
     * 自身范围。
     *
     * @return 固定 null。
     */
    public function getArea():Rectangle {
        return null;
    }

    /**
     * 受击范围。
     *
     * @return 固定 null。
     */
    public function getBodyArea():Rectangle {
        return null;
    }

    /**
     * 当前攻击数据。
     *
     * @return 固定 null。
     */
    public function getCurrentHits():Array {
        return null;
    }

    /**
     * 是否允许穿出地图左右和上沿。
     *
     * @return 固定 true。
     */
    public function allowCrossMapXY():Boolean {
        return true;
    }

    /**
     * 是否允许穿出地图底边。
     *
     * @return 固定 true。
     */
    public function allowCrossMapBottom():Boolean {
        return true;
    }

    /**
     * 是否贴边。
     *
     * @return 固定 false。
     */
    public function getIsTouchSide():Boolean {
        return false;
    }

    /**
     * 空实现。
     *
     * @param v 是否贴边。不使用。
     */
    public function setIsTouchSide(v:Boolean):void {

    }

    /**
     * 空实现。
     *
     * @param v 速度倍率。不使用。
     */
    public function setSpeedRate(v:Number):void {

    }

    /**
     * 释放像素并清空引用。参数为 false 时什么都不做，销毁标记也不变。不从父级移除位图。
     *
     * @param dispose 为 true 时释放。默认 true。
     * @example
     * <listing version="3.0">
     * view.destroy();
     * </listing>
     */
    public function destroy(dispose:Boolean = true):void {
        if (dispose) {
            clearBitmapData();
            _isDestroyed   = true;
            this.target    = null;
            _filter        = null;
            _filterOffset  = null;
            _targetFighter = null;
            _targetBounds  = null;
            _targetDisplay = null;
            _cacheKey      = null;
        }
    }

    private function renderBitmapData():void {
        if (_targetFighter) {
            var curFrame:int = _targetFighter.getMC().getCurrentFrameCount();
            if (curFrame == _bitmapFrame) {
                return;
            }
            _bitmapFrame = curFrame;
        }

        var cache:DisplayFrameBitmapCache = DisplayFrameBitmapCache.I;
        var key:String                    = buildCacheKey();
        var bd:BitmapData                 = cache.drawFilter(_targetDisplay, _filter, _filterOffset, key);

        clearBitmapData();
        _bitmap.bitmapData = bd;
        _cacheKey          = key;
        _bdCached          = cache.isFilterCached(key, bd);
        if (_bdCached) {
            cache.retainFilter(key);
        }

        _targetBounds = _targetDisplay.getBounds(_targetDisplay);
    }

    private function buildCacheKey():String {
        if (!_targetFighter || !_targetFighter.data || !_targetFighter.data.id) {
            return null;
        }
        var pose:String = DisplayFrameBitmapCache.buildPoseKey(_targetFighter);
        if (!pose) {
            return null;
        }
        return DisplayFrameBitmapCache.buildFilterKey(
                _targetFighter.data.id, pose, _filter, _filterOffset
        );
    }

    private function clearBitmapData():void {
        if (!_bitmap || !_bitmap.bitmapData) {
            return;
        }
        if (_bdCached) {
            if (_cacheKey) {
                DisplayFrameBitmapCache.I.releaseFilter(_cacheKey);
            }
        }
        else {
            BitmapDataPool.I.release(_bitmap.bitmapData);
        }
        _bitmap.bitmapData = null;
        _bdCached          = false;
        _cacheKey          = null;
    }

}
}
