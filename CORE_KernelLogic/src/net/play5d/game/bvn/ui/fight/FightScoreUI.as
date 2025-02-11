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
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.MCNumber;

public class FightScoreUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FightScoreUI(ui:score_mc) {
        _ui = ui;

        var txtCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight, 'txtmc_score');

        _nummc = new MCNumber(txtCls, 0, 1, 10, 10);
        _ui.ct.addChild(_nummc);
    }
    private var _ui:score_mc;
    private var _nummc:MCNumber;

    public function setScore(v:int):void {
        _nummc.number = v;
    }

}
}
