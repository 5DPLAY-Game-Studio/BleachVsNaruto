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

package net.play5d.game.bvn.ui.fight {
import flash.display.DisplayObject;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.vos.FighterVO;

public class FightFaceUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FightFaceUI(ui:$fight$MC_hpBarFace) {
        _ui = ui;
    }
    private var _ui:$fight$MC_hpBarFace;

    public function setData(v:FighterVO):void {
        if (!v) {
            _ui.visible = false;
            return;
        }

        _ui.visible = true;

        var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(v);
        if (faceImg) {
            _ui.ct.addChild(faceImg);
        }
    }

    public function setDirect(v:int):void {
    }

}
}
