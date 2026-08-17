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

package net.play5d.game.bvn.ctrler.game_ctrls {
import flash.geom.ColorTransform;

import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.views.effects.FollowEffectView;

/**
 * 对局 Sprite 遍历与同角色染色。
 *
 * <p>依赖运行时 <code>GameCtrl</code> / 对局数据，不属于通用 MC 工具。</p>
 *
 * @see GameCtrl
 */
public class GameSpriteUtil {

    /**
     * 使用回调遍历当前对局 Sprite。
     *
     * @param back 回调，参数为 <code>IGameSprite</code>。
     */
    public static function renderGameSpritesCB(back:Function):void {
        var gameStage:GameStage = GameCtrl.I.gameState;
        if (!gameStage) {
            return;
        }

        var gameSprites:Vector.<IGameSprite> = gameStage.getGameSprites();
        if (!gameSprites || gameSprites.length == 0) {
            return;
        }

        for (var i:int = 0; i < gameSprites.length; i++) {
            var sp:IGameSprite = gameSprites[i] as IGameSprite;

            if (back != null) {
                back(sp);
            }

            if (!sp || sp.isDestroyed()) {
                i--;
            }
        }
    }

    /**
     * 更改游戏 Sprite 颜色，默认绿色偏移 -85。
     *
     * @param sp 指定 <code>IGameSprite</code>。
     * @param ct 颜色变换通道。
     */
    public static function changeSpColor(sp:IGameSprite, ct:ColorTransform = null):void {
        if (!sp) {
            return;
        }

        ct ||= new ColorTransform(
                1, 1, 1, 1,
                0, -85, 0, 0
        );

        sp.colorTransform = ct;
    }

    /**
     * 自动更改游戏 Sprite 颜色（同角色 / 同辅助时）。
     *
     * @param sp 指定 <code>IGameSprite</code>。
     * @param owner 所有者。
     * @param ct 颜色变换通道。
     */
    public static function autoChangeSpColor(
            sp:IGameSprite,
            owner:IGameSprite = null,
            ct:ColorTransform = null):void
    {
        if (!sp) {
            return;
        }

        if (!owner) {
            changeSpColor(sp, ct);
            return;
        }

        if (TeamID.TEAM_2 != owner.team.id) {
            return;
        }

        var isSameFighter:Boolean  = GameCtrl.I.gameRunData.isSameFighter;
        var isSameAssister:Boolean = GameCtrl.I.gameRunData.isSameAssister;

        if (sp is Assister) {
            if (isSameAssister) {
                changeSpColor(sp, ct);
            }
        }
        else if (sp is FighterAttacker) {
            if (owner is FighterMain && isSameFighter ||
                owner is Assister && isSameAssister)
            {
                changeSpColor(sp, ct);
            }
        }
        else if (sp is Bullet || sp is FollowEffectView) {
            if (owner is FighterMain && isSameFighter ||
                owner is Assister && isSameAssister)
            {
                changeSpColor(sp, ct);
            }
            else if (owner is FighterAttacker) {
                owner = (owner as FighterAttacker).getOwner();
                autoChangeSpColor(sp, owner, ct);
            }
        }
    }

}
}
