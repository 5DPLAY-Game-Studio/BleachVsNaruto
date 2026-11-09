/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package {
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;

/**
 * 获取场上游戏元件列表，可按队伍与条件筛选。
 *
 * <p><code>teamId</code> 为 <code>0</code> 或 <code>TeamID.UNKNOWN</code> 时不按队伍过滤。
 * <code>gameState</code> 未就绪时返回空向量。条件函数先于队伍判断执行。
 * 无 <code>team</code> 的元件在按队伍筛选时被跳过。返回的向量是新建的，里面仍是场上的元件。</p>
 *
 * @param teamId 队伍 ID；默认 <code>0</code>（视为不过滤）。
 * @param condition 筛选函数 <code>function(sp:IGameSprite):Boolean</code>；
 *                  返回 <code>false</code> 则排除；可为 <code>null</code>。
 * @return 符合条件的元件向量（新实例，可安全修改）。
 * @example
 * <listing version="3.0">
 * var bullets:Vector.&lt;IGameSprite&gt; = GetGameSprites(TeamID.TEAM_2, function(sp:IGameSprite):Boolean {
 *     return sp is Bullet;
 * });
 * </listing>
 * @see net.play5d.game.bvn.data.TeamID
 * @see net.play5d.game.bvn.interfaces.IGameSprite
 */
public function GetGameSprites(teamId:int = 0, condition:Function = null):Vector.<IGameSprite> {
    var result:Vector.<IGameSprite> = new Vector.<IGameSprite>();
    var stage:GameStage             = GameCtrl.I.gameState;
    if (!stage) {
        return result;
    }

    if (teamId == 0) {
        teamId = TeamID.UNKNOWN;
    }

    var filterTeam:Boolean               = teamId != TeamID.UNKNOWN;
    var gameSprites:Vector.<IGameSprite> = stage.getGameSprites();
    if (!gameSprites) {
        return result;
    }

    for each (var sp:IGameSprite in gameSprites) {
        if (condition != null && !condition(sp)) {
            continue;
        }
        if (filterTeam) {
            if (!sp.team || sp.team.id != teamId) {
                continue;
            }
        }
        result[result.length] = sp;
    }

    return result;
}
}
