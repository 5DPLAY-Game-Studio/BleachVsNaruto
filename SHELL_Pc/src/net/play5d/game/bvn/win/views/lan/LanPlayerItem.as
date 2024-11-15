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
import flash.events.MouseEvent;

import net.play5d.game.bvn.win.data.ClientVO;
import net.play5d.game.bvn.win.data.LanGameModel;
import net.play5d.game.bvn.win.utils.UIAssetUtil;

public class LanPlayerItem {
    public function LanPlayerItem() {
        ui                 = UIAssetUtil.I.createDisplayObject('player_item_mc');
        ui.btn_out.visible = false;
        ui.btn_out.addEventListener(MouseEvent.CLICK, outHandler);
    }
    public var ui:MovieClip;
    public var onOut:Function;
    private var _client:ClientVO;

    public function setOwner():void {
        ui.txt.text = LanGameModel.I.playerName;
        ui.type.gotoAndStop(1);
    }

    public function setPlayer(cv:ClientVO):void {
        _client     = cv;
        ui.txt.text = cv.name;
        ui.type.gotoAndStop(2);
        ui.btn_out.visible = true;
    }

    public function setLooker(cv:ClientVO):void {
        _client     = cv;
        ui.txt.text = cv.name;
        ui.type.gotoAndStop(3);
        ui.btn_out.visible = true;
    }

    private function outHandler(e:MouseEvent):void {

        if (onOut != null) {
            onOut(this);
        }
    }

}
}
