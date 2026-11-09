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

package net.play5d.game.bvn.ui {
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.TeamID;

/**
 * 胜利标。胜场不是 1 或 2，或作品不是 0 和 1 时，什么都不播。角色为 null 时直接返回。1 胜时 1 队用 <code>w1</code>，其它队用 <code>w2</code>。2 胜时对调。
 */
public class WinUI {

    /**
     * 记下胜利影片和队伍。
     *
     * @param ui 胜利影片。
     * @param team 队伍编号。
     */
    public function WinUI(ui:$fight$MC_win, team:int) {
        _ui   = ui;
        _team = team;
    }
    private var _team:int;

    private var _ui:$fight$MC_win;

    /**
     * 胜利影片。
     *
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = win.ui;
     * </listing>
     */
    public function get ui():DisplayObject {
        return _ui;
    }

    /**
     * 按胜场和作品播放入场。角色为 null，或胜场不是 1 和 2 时直接返回。
     *
     * @param fighter 胜利角色。
     * @param wins 胜场，只用 1 和 2。
     * @example
     * <listing version="3.0">
     * win.show(fighter, 1);
     * </listing>
     */
    public function show(fighter:FighterVO, wins:int):void {
        if (!fighter) {
            return;
        }

        var playmc:MovieClip;

        switch (wins) {
        case 1:
            playmc = _team == TeamID.TEAM_1 ? _ui.w1 : _ui.w2;
            break;
        case 2:
            playmc = _team == TeamID.TEAM_1 ? _ui.w2 : _ui.w1;
            break;
        }

        if (!playmc) {
            return;
        }

        switch (fighter.comicType) {
        case 0:
            playmc.gotoAndPlay('in_bleach');
            break;
        case 1:
            playmc.gotoAndPlay('in_naruto');
            break;
        }

    }

}
}
