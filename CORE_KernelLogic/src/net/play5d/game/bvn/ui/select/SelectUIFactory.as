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

package net.play5d.game.bvn.ui.select {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.utils.ResUtils;

public class SelectUIFactory {
    include '../../../../../../../include/_INCLUDE_.as';


    public static function createSelecter(playerType:int = 1):SelecterItemUI {
        var ui:SelecterItemUI = new SelecterItemUI(playerType);

        ui.inputType = playerType == 1 ? GameInputType.P1 : GameInputType.P2;
        ui.selectVO  = playerType == 1 ? GameData.I.p1Select : GameData.I.p2Select;

        var groupClassName:String = playerType == 1 ? '$select$SP_selectBarItemP1' : 'selected_item_p2_mc';

        var groupClass:Class = ResUtils.I.getItemClass(ResUtils.swfLib.select, groupClassName);

        var group:SelectedFighterGroup = new SelectedFighterGroup(groupClass);
        group.x                        = playerType == 1 ? 10 : GameConfig.GAME_SIZE.x - 265;
        group.y                        = GameConfig.GAME_SIZE.y - 80;

        group.addFighter(null);

        ui.group = group;

        return ui;
    }


}
}
