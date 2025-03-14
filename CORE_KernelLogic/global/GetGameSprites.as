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

package {
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 全局函数，获得场上游戏元件
 * <p/>
 * 下列代码演示如何使用全局方法 <code>GetGameSprites()</code> 获得场上 P2 的飞行道具游戏元件：
 * <listing version="3.0">
 // 游戏中的 Bullet 类引用
 var Bullet:Class;
 var gameSprites:Vector.<IGameSprite> = GetGameSprites(2, condition);

 function condition(sp:IGameSprite):Boolean {
     return sp is Bullet；
 }
 * </listing>
 *
 * @param         teamId    队伍 ID
 * @param         condition 筛选条件 return Boolean
 *
 * @see           int
 * @see           Function
 * @see           Vector
 * @see           IGameSprite
 *
 * @return        场上游戏元件
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function GetGameSprites(teamId:int = 0, condition:Function = null):Vector.<IGameSprite> {
    teamId ||= TeamID.UNKNOWN;

    var newGameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>();
    var gameSprites:Vector.<IGameSprite>    = GameCtrl.I.gameState.getGameSprites();

    for each (var sp:IGameSprite in gameSprites) {
        if (condition != null && !condition(sp)) {
            continue;
        }

        if (teamId == TeamID.UNKNOWN || teamId == sp.team.id) {
            newGameSprites.push(sp);
        }
    }

    return newGameSprites;
}

}
