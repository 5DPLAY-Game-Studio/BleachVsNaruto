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

package net.play5d.game.bvn.win {
import flash.display.Stage;
import flash.events.KeyboardEvent;

import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameData;

public class MosouDebugger {


    public static function init(param1:Stage):void {
        param1.addEventListener('keyUp', keyHandler);
    }

    public function MosouDebugger() {
        super();
    }

    private static function keyHandler(param1:KeyboardEvent):void {
        switch (int(param1.keyCode) - 112) {
        case 0:
            GameData.I.mosouData.addMoney(100000);
            break;
        case 1:
            GameData.I.mosouData.addFighterExp(100000);
            break;
        case 2:
            GameCtrl.I.getMosouCtrl().anyWaypassMission();
        }
    }
}
}
