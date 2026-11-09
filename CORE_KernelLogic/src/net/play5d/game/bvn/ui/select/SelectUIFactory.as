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
import net.play5d.game.bvn.data.GameInputType;
import net.play5d.game.bvn.utils.ResUtils;

/**
 * 选人光标工厂。玩家编号不是 1 时都当成 2P，包括 0。条上会先放一个空位。
 */
public class SelectUIFactory {

    /**
     * 建好光标、输入槽和已选条。
     *
     * @param playerType 默认 1。只有 1 使用 1P 的选择和输入。
     * @return 光标。
     * @throws TypeError 存档或资源缺失时。
     * @example
     * <listing version="3.0">
     * var cursor:SelectorItemUI = SelectUIFactory.createSelector(1);
     * </listing>
     */
    public static function createSelector(playerType:int = 1):SelectorItemUI {
        var ui:SelectorItemUI = new SelectorItemUI(playerType);

        ui.inputType = playerType == 1 ? GameInputType.P1 : GameInputType.P2;
        ui.selectVO  = playerType == 1 ? GameData.I.p1Select : GameData.I.p2Select;

        var groupClassName:String = playerType == 1 ? '$select$SP_selectBarItemP1' : '$select$SP_selectBarItemP2';

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
