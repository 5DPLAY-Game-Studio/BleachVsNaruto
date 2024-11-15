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

import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.utils.KyoBtnUtils;

public class LANRoomPlayerItem {
    public function LANRoomPlayerItem(id:String, name:String) {

        this.id = id;

        ui          = UIAssetUtil.I.createDisplayObject('player_item_mc');
        ui.txt.text = name;
        ui.type.gotoAndStop(2);
        ui.btn_out.visible = false;
    }
    public var ui:MovieClip;
    public var id:String;

    public function enableOut():void {
        ui.btn_out.visible = true;
        KyoBtnUtils.initBtn(ui.btn_out, outClickHandler);
    }

    public function destory():void {
        if (ui.btn_out && ui.btn_out.visible) {
            KyoBtnUtils.disposeBtn(ui.btn_out);
        }
    }

    private function outClickHandler():void {
        LANServerCtrl.I.kickOut(id);
    }

}
}
