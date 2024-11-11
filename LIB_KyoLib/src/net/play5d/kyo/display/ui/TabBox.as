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
import flash.events.Event;
import flash.events.MouseEvent;

public class TabBox extends BaseBox {
    public function TabBox(gapX:Number = 5, gapY:Number = 0) {
        this.gapX = gapX;
        this.gapY = gapY;
    }

    public var selectedTab:ITab;
    private var _lx:Number;
    private var _ly:Number;

    public function get selectedIndex():int {
        return _instances.indexOf(selectedTab);
    }

    protected override function build():void {
        _lx = _ly = 0;
        if (!_instances || _instances.length < 1) {
            return;
        }
        update();
        select(0);
    }

    protected override function buildByRepeater():void {
        if (repeater) {
            _instances = repeater.getItems();
        }
        build();
    }

    public function update():void {
        var e:int = numChildren > _instances.length ? numChildren : _instances.length;
        for (var i:int; i < e; i++) {
            var dc:DisplayObject;
            try {
                dc = getChildAt(i);
            }
            catch (e:Error) {
                dc = null;
            }
            var t:ITab = _instances[i];
            if (t && !dc) {
                addChildItem(t);
            }
            if (!t && dc) {
                removeChild(dc);
                dc = null;
            }
        }
    }

    public function select(id:int):void {
        if (_instances) {
            selectTab(_instances[id]);
        }
    }

    private function addChildItem(d:ITab):void {
        var dp:DisplayObject;
        if (d is DisplayObject) {
            dp = d as DisplayObject;
        }
        else {
            dp = d.display;
        }
        dp.x = _lx;
        dp.y = _ly;
        addChild(dp);
        d.addEventListener(MouseEvent.CLICK, mouseHandler, false, 0, true);
        if (gapX > 0) {
            _lx += dp.width + gapX;
        }
        if (gapY > 0) {
            _ly += dp.height + gapY;
        }
    }

    private function selectTab(v:ITab):void {
        selectedTab = v;
        if (v.selected == true) {
            return;
        }
        for each(var i:ITab in _instances) {
            i.selected = false;
        }
        v.selected = true;
    }

    private function mouseHandler(e:MouseEvent):void {
        selectTab(e.currentTarget as ITab);
        dispatchEvent(new Event(Event.SELECT));
    }


}
}
