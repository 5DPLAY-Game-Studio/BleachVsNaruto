/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;

/**
 * 队伍 ID
 */
public class TeamID {
    include '../../../../../../include/_INCLUDE_.as';

    // 未知队伍
    public static const UNKNOWN:int = -1;

    // 队伍 1
    public static const TEAM_1:int = 1;
    // 队伍 2
    public static const TEAM_2:int = 2;

    /**
     * 获得对象的 TeamVO
     * @param obj 指定 BaseGameSprite 或者 TeamVO
     * @return 是否为 【队伍 1】
     */
    private static function getTeamVO(obj:Object):TeamVO {
        if (!obj) {
            return null;
        }

        var team:TeamVO = null;

        if (obj is BaseGameSprite) {
            var sp:BaseGameSprite = obj as BaseGameSprite;
            team = sp.team;
        }
        else if (obj is TeamVO) {
            team = obj as TeamVO;
        }

        return team;
    }

    /**
     * 检测是否为 【队伍 1】
     * @param obj 指定 BaseGameSprite 或者 TeamVO
     * @return 是否为 【队伍 1】
     */
    public static function isTeam1(obj:Object):Boolean {
        var team:TeamVO = getTeamVO(obj);

        return team && team.id == TEAM_1;
    }

    /**
     * 检测是否为 【队伍 2】
     * @param obj 指定 BaseGameSprite 或者 TeamVO
     * @return 是否为 【队伍 2】
     */
    public static function isTeam2(obj:Object):Boolean {
        return !isTeam1(obj);
    }
}
}
