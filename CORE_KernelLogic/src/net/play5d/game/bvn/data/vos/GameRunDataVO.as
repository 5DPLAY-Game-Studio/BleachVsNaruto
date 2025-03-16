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

package net.play5d.game.bvn.data.vos {
import net.play5d.game.bvn.data.*;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IInstanceVO;

//import net.play5d.game.bvn.data.musou.MosouWaveRunVO;
/**
 * 记录运行游戏时需要的相关数据
 */
public class GameRunDataVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public const p1FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
    public const p2FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();

    public var map:MapVO;
    public var p1Wins:int = 0;
    public var p2Wins:int = 0;
    public var lastWinnerTeam:TeamVO;
    public var continueLoser:FighterMain;
    public var lastWinner:FighterMain;
    public var lastWinnerHp:int = 1000;
    public var lastLoserData:FighterVO;
    public var lastLoserQi:int = 0;
    public var round:int = 1;
    public var gameTime:int;
    public var gameTimeMax:int; //-1时，无限时
    public var isTimerOver:Boolean;

//		public var winner:FighterMain;
//		public var loser:FighterMain;
    public var isDrawGame:Boolean;

    /**
     * 获取角色已胜利局数
     * @param fighter 角色
     * @return 角色已胜利局数
     */
    public function getWins(fighter:FighterMain):int {
        switch (fighter.team.id) {
        case TeamID.TEAM_1:
            return p1Wins;
        case TeamID.TEAM_2:
            return p2Wins;
        }

        return 0;
    }

    public function reset():void {
        p1Wins = 0;
        p2Wins = 0;
        round  = 1;

        lastWinnerTeam = null;
        lastWinner     = null;

        lastLoserData = null;
        lastLoserQi   = 0;

        isTimerOver = false;
        isDrawGame  = false;

        lastWinnerHp = GameData.I.config.fighterHP;

        gameTimeMax = GameData.I.config.fightTime;
        gameTime    = gameTimeMax;

        continueLoser = null;

    }

    public function clear():void {
        map            = null;
        lastWinnerTeam = null;
        lastWinner     = null;
        lastLoserData  = null;
        continueLoser  = null;
    }

    public function nextRound():void {
        round++;
        gameTime    = gameTimeMax;
        isTimerOver = false;
//			lastWinner = null;
    }

    public function setAllowLoseHP(v:Boolean):void {
        if (p1FighterGroup && p1FighterGroup.currentFighter) {
            p1FighterGroup.currentFighter.isAllowLoseHP = v;
        }
        if (p2FighterGroup && p2FighterGroup.currentFighter) {
            p2FighterGroup.currentFighter.isAllowLoseHP = v;
        }
    }

}
}
