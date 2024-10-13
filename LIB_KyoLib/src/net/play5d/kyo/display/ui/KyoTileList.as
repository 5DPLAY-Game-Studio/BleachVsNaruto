/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
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

package net.play5d.kyo.display.ui {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoUtils;

/**
 * 表格排行样式列表
 * @author kyo
 */
public class KyoTileList extends Sprite {
    /**
     * @param displays 元件数组 DisplayObject
     * @param hrow 横排最大个数
     * @param vrow 竖排最大个数
     */
    public function KyoTileList(displays:Array = null, hrow:int = int.MAX_VALUE, vrow:int = 1) {
        _hrow = hrow;
        _vrow = vrow;
        setDisplays(displays);
    }
    /**
     * 元件与元件间的间隔
     */
    public var gap:Point        = new Point(5, 5);
    public var unitySize:Point  = new Point();
    public var HLine:Class;
    public var VLine:Class;
    public var showNum:int      = -1;
    public var displays:Array;
    public var startPos:Point   = new Point();
    public var scrollBar:IKyoScrollBar;
    /**
     * 大小位置保持一致
     */
    public var lockSize:Boolean = false;
    public var scrollHadd:Boolean = true;
    public var rowV:int;
    protected var _width:Number  = 0;
    protected var _height:Number = 0;
    private var _hrow:int;
    private var _vrow:int;

    private var _page:int      = 1;

    public function get page():int {
        return _page;
    }

    public function set page(value:int):void {
        if (_page == value) {
            return;
        }
        _page = value;
        update();
    }

    private var _perPage:int;

    public function get perPage():int {
        return _perPage;
    }

    private var _totalPage:int = 1;

    public function get totalPage():int {
        return _totalPage;
    }

    private var _maskSize:Point;

    public function get maskSize():Point {
        return _maskSize;
    }

    public function set maskSize(value:Point):void {
        _maskSize  = value;
        scrollRect = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
    }

    private var _scrollPos:Point;

    public function get scrollPos():Point {
        return _scrollPos;
    }

    public function set scrollPos(value:Point):void {
        _scrollPos = value;

        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);

        if (scrollHadd) {
            rect.x = _scrollPos.x * (
                    _width + unitySize.x - _maskSize.x
            );
            rect.y = _scrollPos.y * (
                    _height + unitySize.y - _maskSize.y
            );
        }
        else {
            rect.x = _scrollPos.x * (
                    _width - _maskSize.x
            );
            rect.y = _scrollPos.y * (
                    _height - _maskSize.y
            );
        }

        scrollRect = rect;
    }

    public function get length():uint {
        return displays.length;
    }

    public function get scrollV():Number {
        return scrollRect.y;
    }

    public function set scrollV(v:Number):void {
        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
        rect.y             = v;
        scrollRect         = rect;
    }

    public function get scrollH():Number {
        return scrollRect.x;
    }

    public function set scrollH(v:Number):void {
        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
        rect.x             = v;
        scrollRect         = rect;
    }

    public override function getChildIndex(child:DisplayObject):int {
        return displays.indexOf(child);
    }

    public override function removeChild(child:DisplayObject):DisplayObject {
        KyoUtils.array_removeItem(displays, child);
        var d:DisplayObject = super.removeChild(child);

        update();
        return d;
    }

    public function setDisplays(v:Array):void {
        removeAllChildren();
        displays = v;
        if (displays && displays.length > 0) {
            update();
        }
    }

    public function addDisplay(d:DisplayObject):void {
        displays ||= [];
        displays.push(d);
        update();
    }

    public function removeAllChildren():void {
        displays = [];
        KyoUtils.removeAllChildren(this);
    }

    public function removeDisplay(d:DisplayObject, updateNow:Boolean = true):void {
        var id:int = displays.indexOf(d);
        if (id == -1) {
            return;
        }
        removeDisplayAt(id, updateNow);
    }

    public function removeDisplayAt(id:int, updateNow:Boolean = true):void {
        displays.splice(id, 1);
        if (updateNow) {
            update();
        }
    }

    public function addItemsListener(event:String, handler:Function):void {
        for each(var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }
            d.addEventListener(event, handler);
        }
    }

    public function removeItemsListener(event:String, handler:Function):void {
        for each(var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }
            d.removeEventListener(event, handler);
        }
    }

    public function anyoneDoFunction(fun:String, ...params):void {
        for each(var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }
            var f:Function = d[fun];
            f.apply(null, params);
        }
    }

    public function appendChild(d:Object, index:int):void {
        KyoUtils.array_pushAt(displays, d, index);
        update();
    }

    public function update():void {
        if (_hrow < int.MAX_VALUE && _vrow < int.MAX_VALUE) {
            _perPage   = _hrow * _vrow;
            _totalPage = Math.ceil(displays.length / _perPage);
        }
        _page = KyoUtils.num_fixRange(_page, new Point(1, _totalPage));

        list(_hrow, _vrow);
        if (scrollBar) {
            if (_width > maskSize.x || _height > maskSize.y) {
                scrollBar.enabled = true;
                if (!scrollBar.hasEventListener(KyoUIEvent.UPDATE)) {
                    scrollBar.addEventListener(KyoUIEvent.UPDATE, srollUpdate);
                }
            }
            else {
                scrollBar.enabled = false;
                scrollPos         = new Point();
                scrollBar.update(0);
            }
        }

        dispatchEvent(new Event(Event.CHANGE));
    }

    public function list(h:int, v:int):void {
        KyoUtils.removeAllChildren(this);

        var p:Point = startPos.clone();
        var s:int   = (
                              _page - 1
                      ) * _perPage;
        var e:int;
        if (h >= int.MAX_VALUE || v >= int.MAX_VALUE) {
            e = int.MAX_VALUE;
        }
        else {
            e = s + h * v;
        }

        if (e > displays.length) {
            e = displays.length;
        }
        rowV = 0;
        var firsted:Boolean;
        var overh:Boolean;
        for (var i:int = s; i < e; i++) {
            var d:DisplayObject = displays[i];
            if (!d) {
                continue;
            }

            if (!firsted) {
                firsted = true;
                if (unitySize.x == 0) {
                    unitySize.x = d.width;
                }
                if (unitySize.y == 0) {
                    unitySize.y = d.height;
                }
                _width  = unitySize.x;
                _height = unitySize.y;
            }

            d.x = p.x;
            d.y = p.y;
            if ((
                        i + 1
                ) % h == 0) {
                overh         = true;
                p.x           = startPos.x;
                var yy:Number = lockSize ? unitySize.y : d.height;
                p.y += yy + gap.y;
                if (VLine) {
                    var vl:DisplayObject = new VLine();
                    vl.x                 = 0;
                    vl.y                 = p.y - gap.y / 2;
                    addChild(vl);
                }
                if (_height < p.y) {
                    _height = p.y;
                }
            }
            else {
                if (overh) {
                    rowV++;
                    overh = false;
                }
                var xx:Number = lockSize ? unitySize.x : d.width;
                p.x += xx + gap.x;
                if (_width < p.x) {
                    _width = p.x;
                }
            }
            addChild(d);
        }

        if (h % _hrow != 0) {
            xx = lockSize ? unitySize.x : d.width;
            _width += xx;
        }
        if (rowV % _vrow != 0) {
            yy = lockSize ? unitySize.y : d.height;
            _height += yy;
        }

    }

    public function alignCenterH(ctWidth:Number):void {
        if (!displays || displays.length < 1) {
            return;
        }
        var w:Number;
        if (lockSize && unitySize) {
            var hw:int = Math.min(displays.length, _hrow);
            w          = (
                         unitySize.x + gap.x
                         ) * (
                                 hw - 1
                         ) + unitySize.x;
        }
        else {
            w = _width;
        }
        x = (
                    ctWidth - w
            ) / 2;
    }

    protected function updateScrollBar():void {
        if (scrollBar) {
            scrollBar.update(_scrollPos.y);
        }
    }

    private function srollUpdate(e:KyoUIEvent):void {
        var pos:Point = e.params as Point;
        scrollPos     = pos;
    }

}
}
