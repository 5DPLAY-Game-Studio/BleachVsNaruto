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

package net.play5d.game.bvn.win.views.lan {
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.utils.LANUtils;
import net.play5d.game.bvn.win.utils.UIAssetUtil;

public class HostListItem {
    public function HostListItem() {
        ui               = UIAssetUtil.I.createDisplayObject('hostlist_item');
        ui.mouseChildren = false;
        ui.buttonMode    = true;
    }
    public var ui:MovieClip;
    public var data:HostVO;
    private var _mouseListener:Function;
    private var _focus:Boolean;

    public function setData(data:HostVO):void {

        this.data = data;

        ui.txt_name.text = data.getListName();
        ui.txt_mode.text = data.getGameModeStr();
        ui.txt_time.text = LANUtils.getTimeStr(data.updateTime);
        ui.lock.visible  = data.password != null && data.password != '';
    }

    public function focus(v:Boolean):void {
        if (_focus == v) {
            return;
        }

        _focus = v;

        if (v) {
            ui.focusmc.gotoAndPlay('loop');
        }
        else {
            ui.focusmc.gotoAndStop(1);
        }
    }

    public function setMouseListener(listener:Function):void {

        _mouseListener = listener;

        ui.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
        ui.addEventListener(MouseEvent.CLICK, mouseHandler);
    }

    public function removeMouseListener():void {
        _mouseListener = null;
        ui.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
        ui.removeEventListener(MouseEvent.CLICK, mouseHandler);
    }

    private function mouseHandler(e:Event):void {
        if (_mouseListener != null) {
            _mouseListener(e.type, this);
        }
    }

}
}
