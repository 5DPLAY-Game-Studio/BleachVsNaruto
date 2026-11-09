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

/**
 * 一局进行中的双方、胜场和计时。
 *
 * <p>双方队伍是构造时建好的常量，不会换成另一份。<code>reset</code> 把胜场、回合和胜负标记清掉，并按配置重写时间和胜者体力记录，地图不动。
 * <code>clear</code> 只丢掉地图、胜负引用和续关角色。<code>nextRound</code> 只加回合、把时间设回上限，并清掉时间到标记。</p>
 *
 * @see GameRunFighterGroup
 */
public class GameRunDataVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /** P1 队伍。 */
    public const p1FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
    /** P2 队伍。 */
    public const p2FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();

    /**
     * 本局地图。
     *
     * @default null
     */
    public var map:MapVO;
    /**
     * P1 胜场。
     *
     * @default 0
     */
    public var p1Wins:int       = 0;
    /**
     * P2 胜场。
     *
     * @default 0
     */
    public var p2Wins:int       = 0;
    /**
     * 上一回合胜者的队伍。
     *
     * @default null
     */
    public var lastWinnerTeam:TeamVO;
    /**
     * 续关要留下的败者。
     *
     * @default null
     */
    public var continueLoser:FighterMain;
    /**
     * 上一回合胜者。
     *
     * @default null
     */
    public var lastWinner:FighterMain;
    /**
     * 记下来的胜者体力。<code>reset</code> 时改成配置里的体力。
     *
     * @default 1000
     */
    public var lastWinnerHp:int = 1000;
    /**
     * 上一回合败者的数据。
     *
     * @default null
     */
    public var lastLoserData:FighterVO;
    /**
     * 上一回合败者的气。
     *
     * @default 0
     */
    public var lastLoserQi:int  = 0;
    /**
     * 当前回合，从 1 开始。
     *
     * @default 1
     */
    public var round:int        = 1;
    /**
     * 剩余时间，单位是逻辑帧。
     *
     * @default 0
     */
    public var gameTime:int;
    /**
     * 时间上限。-1 表示不限时。
     *
     * @default 0
     */
    public var gameTimeMax:int;
    /**
     * 是否已经时间到。
     *
     * @default false
     */
    public var isTimerOver:Boolean;
    /**
     * 是否平局。
     *
     * @default false
     */
    public var isDrawGame:Boolean;

    /**
     * 双方当前角色是不是同一个 id。
     *
     * <p>任一侧没有 id 时为 <code>false</code>。</p>
     *
     * @return 相同为 <code>true</code>。
     */
    public function get isSameFighter():Boolean {
        if (!p1FighterGroup || !p2FighterGroup) {
            return false;
        }

        var p1Id:String = p1FighterGroup.currentFighterId;
        var p2Id:String = p2FighterGroup.currentFighterId;

        return p1Id && p2Id && p1Id == p2Id;
    }

    /**
     * 双方当前援助是不是同一个 id。
     *
     * <p>任一侧没有 id 时为 <code>false</code>。</p>
     *
     * @return 相同为 <code>true</code>。
     */
    public function get isSameAssister():Boolean {
        if (!p1FighterGroup || !p2FighterGroup) {
            return false;
        }

        var p1Id:String = p1FighterGroup.currentAssisterId;
        var p2Id:String = p2FighterGroup.currentAssisterId;

        return p1Id && p2Id && p1Id == p2Id;
    }

    /**
     * 取这个角色所在队伍的胜场。
     *
     * <p>不是 1 队或 2 队时返回 0。角色或队伍为空时抛错。</p>
     *
     * @param fighter 角色。
     * @return 胜场。
     * @example
     * <listing version="3.0">
     * var wins:int = data.getWins(fighter);
     * </listing>
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

    /**
     * 清掉胜场和胜负标记，并把时间和胜者体力记录写成当前配置。
     *
     * <p>地图和双方队伍不动。配置还没就绪时抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * data.reset();
     * </listing>
     */
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

    /**
     * 丢掉地图、胜负引用和续关角色。
     *
     * <p>胜场、回合和时间不动。</p>
     *
     * @example
     * <listing version="3.0">
     * data.clear();
     * </listing>
     */
    public function clear():void {
        map            = null;
        lastWinnerTeam = null;
        lastWinner     = null;
        lastLoserData  = null;
        continueLoser  = null;
    }

    /**
     * 回合加 1，时间设回上限，并清掉时间到标记。
     *
     * <p>平局标记不动。</p>
     *
     * @example
     * <listing version="3.0">
     * data.nextRound();
     * </listing>
     */
    public function nextRound():void {
        round++;
        gameTime    = gameTimeMax;
        isTimerOver = false;
    }

    /**
     * 给双方当前角色写下是否允许掉体力。
     *
     * <p>某一侧没有当前角色时跳过那一侧。</p>
     *
     * @param v 是否允许掉体力。
     * @example
     * <listing version="3.0">
     * data.setAllowLoseHP(false);
     * </listing>
     */
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
