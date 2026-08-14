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
import net.play5d.game.bvn.utils.DisplayFrameBitmapCache;
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
     * 颜色变换通道
     */
    public function get colorTransform():ColorTransform {
        return null;
    }

    /** @private */
    public function set colorTransform(ct:ColorTransform):void {
    }

    public function get direct():int {
        return target.direct;
    }

    /** @private */
    public function set direct(value:int):void {

    }

    public function get x():Number {
        return _bitmap.x;
    }

    /** @private */
    public function set x(v:Number):void {
        _bitmap.x = v;
    }

    public function get y():Number {
        return _bitmap.y;
    }

    /** @private */
    public function set y(v:Number):void {
        _bitmap.y = v;
    }

    public function get team():TeamVO {
        return null;
    }

    /** @private */
    public function set team(v:TeamVO):void {

    }

    public function getActive():Boolean {
        return _isActive;
    }

    public function setActive(v:Boolean):void {
        _isActive = v;
    }

    public function setVolume(v:Number):void {
    }

    public function update(filter:BitmapFilter, filterOffset:Point = null):void {
        _filter       = filter;
        _filterOffset = filterOffset;
        _bitmapFrame  = -1;
    }

    public function renderAnimate():void {
    }

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

    public function isDestroyed():Boolean {
        return _isDestroyed;
    }

    public function getDisplay():DisplayObject {
        return _bitmap;
    }

    public function hit(hitvo:HitVO, target:IGameSprite):void {

    }

    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {

    }

    public function getArea():Rectangle {
        return null;
    }

    public function getBodyArea():Rectangle {
        return null;
    }

    public function getCurrentHits():Array {
        return null;
    }

    public function allowCrossMapXY():Boolean {
        return true;
    }

    public function allowCrossMapBottom():Boolean {
        return true;
    }

    public function getIsTouchSide():Boolean {
        return false;
    }

    public function setIsTouchSide(v:Boolean):void {

    }

    public function setSpeedRate(v:Number):void {

    }

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
