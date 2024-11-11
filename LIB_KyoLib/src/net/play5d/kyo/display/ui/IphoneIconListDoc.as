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
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import net.play5d.kyo.utils.KyoAlign;

public class IphoneIconListDoc extends Sprite {
    public function IphoneIconListDoc(docClass:Class, list:IphoneIconList) {
        super();
        _docClass = docClass;
        _iplist   = list;
        _iplist.addEventListener(IphoneIconListEvent.PAGE_CHANGE, update);
        update();
    }

    public var gap:Point = new Point(20, 0);
    private var _iplist:IphoneIconList;
    private var _docClass:Class;
    private var _list:KyoTileList;

    public function update(...params):void {
        var current:int = _iplist.curPage;
        var total:int   = _iplist.totalPage;

        var ds:Array = [];
        for (var i:int; i < total; i++) {
            var c:MovieClip = new _docClass();
            c.pg            = i + 1;
            c.gotoAndStop((
                                  i + 1 == current
                          ) ? 1 : 2);
            c.addEventListener(MouseEvent.CLICK, onccclick);
            ds.push(c);
        }
        if (!_list) {
            _list           = new KyoTileList();
            _list.unitySize = new Point(11, 11);
            _list.lockSize  = true;
            _list.gap       = gap;
            addChild(_list);
        }
        _list.setDisplays(ds);

        _list.x = 0;
        KyoAlign.centerW(_list, _iplist.touchSize.x);
    }

    public function destory():void {
        if (_iplist) {
            _iplist.removeEventListener(IphoneIconListEvent.PAGE_CHANGE, update);
        }
        if (_list) {
            _list.removeAllChildren();
        }
    }

    private function onccclick(e:MouseEvent):void {
        var c:MovieClip = e.currentTarget as MovieClip;
        _iplist.goPage(c.pg);
//			trace(c.pg);
    }

}
}
