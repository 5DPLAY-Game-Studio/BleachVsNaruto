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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.vos.TeamVO;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 对战回合推进：计时、下一回合构建、小队换人。
 *
 * @see GameCtrl
 */
public class GameRoundCtrl {

    /** @private */
    private var _owner:GameCtrl;

    /**
     * 绑定门面。
     *
     * @param owner <code>GameCtrl</code>。
     */
    public function bind(owner:GameCtrl):void {
        _owner = owner;
    }

    /**
     * 释放引用。
     */
    public function destroy():void {
        _owner = null;
    }

    /**
     * 开始下一回合。
     */
    public function startNextRound():void {
        doBuildNextRound(GameMode.isTeamMode());
    }

    /**
     * 回合结束控制完成后进入下一场。
     */
    public function onEndFinished():void {
        runNext();
    }

    /**
     * 推进对局计时（动画帧节拍）。
     */
    public function renderGameTime():void {
        if (_owner.gameRunData.gameTimeMax != -1) {
            if (++_owner.roundTimeFrame > GameConfig.FPS_ANIMATE) {
                _owner.roundTimeFrame = 0;
                _owner.gameRunData.gameTime--;
                if (_owner.gameRunData.gameTime <= 0) {
                    fightTimeover();
                }
            }
        }
    }

    /**
     * 运行下一个回合。
     */
    private function buildNextRound(isTeamMode:Boolean):void {
        doBuildNextRound(isTeamMode);
    }

    /**
     * 执行构建下一回合。
     *
     * @param isTeamMode 是否为小队模式。
     */
    private function doBuildNextRound(isTeamMode:Boolean):void {
        _owner.gameState.resetFight(_owner.gameRunData.p1FighterGroup, _owner.gameRunData.p2FighterGroup);

        _owner.roundStartCtrl = new GameStartCtrl(_owner.gameState);

        if (isTeamMode) {
            if (_owner.gameRunData.lastWinner) {
                _owner.gameRunData.lastWinner.hp = _owner.gameRunData.lastWinnerHp;
            }

            var loseTeam:int = TeamID.UNKNOWN;
            if (_owner.gameRunData.lastWinnerTeam) {
                loseTeam = TeamID.TEAM_1 == _owner.gameRunData.lastWinnerTeam.id ?
                           TeamID.TEAM_2 :
                           TeamID.TEAM_1;
            }

            _owner.roundStartCtrl.start1v1(
                    _owner.gameRunData.p1FighterGroup.currentFighter,
                    _owner.gameRunData.p2FighterGroup.currentFighter,
                    loseTeam
            );
        }
        else {
            _owner.roundStartCtrl.startNextRound();
        }

        _owner.gameRunData.isDrawGame = false;

        GameEvent.dispatchEvent(GameEvent.ROUND_START);
    }

    private function fightTimeover():void {
        TraceLang('debug.trace.data.game_ctrl.time_over');

        _owner.actionEnable = false;

        var fighter1:FighterMain = _owner.gameRunData.p1FighterGroup.currentFighter;
        var fighter2:FighterMain = _owner.gameRunData.p2FighterGroup.currentFighter;

        _owner.gameRunData.isTimerOver = true;

        if (fighter1.hp == fighter2.hp) {
            _owner.drawGame();
            return;
        }

        if (fighter1.hp > fighter2.hp) {
            _owner.gameEnd(fighter1, fighter2);
        }
        else {
            _owner.gameEnd(fighter2, fighter1);
        }
    }

    private function runNext():void {
        TraceLang('debug.trace.data.game_ctrl.current_mode', {mode: GameMode.currentMode});

        _owner.gameRunData.nextRound();

        if (GameMode.isTeamMode()) {
            if (startNextTeamFight()) {
                buildNextRound(true);
                _owner.gameRunData.lastWinner = null;
                return;
            }
        }

        if (GameMode.isSingleMode()) {
            if (_owner.gameRunData.p1Wins < 2 && _owner.gameRunData.p2Wins < 2) {
                buildNextRound(false);
                _owner.gameRunData.lastWinner = null;
                return;
            }
        }

        _owner.fightFinish();
    }

    private function startNextTeamFight():Boolean {
        if (_owner.gameRunData.isDrawGame) {

            var p1NextFighter:FighterVO = _owner.gameRunData.p1FighterGroup.getNextFighter();
            var p2NextFighter:FighterVO = _owner.gameRunData.p2FighterGroup.getNextFighter();

            if (!p1NextFighter && !p2NextFighter) {
                return true;
            }

            if (p1NextFighter && !p2NextFighter) {
                _owner.gameRunData.lastWinnerTeam = _owner.gameRunData.p1FighterGroup.currentFighter.team;
                return false;
            }

            if (!p1NextFighter && p2NextFighter) {
                _owner.gameRunData.lastWinnerTeam = _owner.gameRunData.p2FighterGroup.currentFighter.team;
                return false;
            }

            nextFighter(_owner.gameRunData.p1FighterGroup);
            nextFighter(_owner.gameRunData.p2FighterGroup);

            return true;
        }

        switch (_owner.gameRunData.lastWinnerTeam.id) {
        case TeamID.TEAM_1:
            return nextFighter(_owner.gameRunData.p2FighterGroup);
        case TeamID.TEAM_2:
            return nextFighter(_owner.gameRunData.p1FighterGroup);
        }

        _owner.gameRunData.lastWinnerTeam = null;

        return true;
    }

    private function nextFighter(fg:GameRunFighterGroup):Boolean {
        if (!fg) {
            return false;
        }

        var team:TeamVO = fg.currentFighter.team;

        var nextFighterData:FighterVO = fg.getNextFighter();
        if (!nextFighterData) {
            return false;
        }

        var nextFighter:FighterMain = GameRunFactory.createFighterByData(nextFighterData, team.id.toString());
        if (!nextFighter) {
            return false;
        }

        if (_owner.gameRunData.lastLoserData) {
            if (_owner.gameRunData.lastLoserData.comicType == nextFighter.data.comicType) {
                nextFighter.qi = _owner.gameRunData.lastLoserQi + 100;
                if (nextFighter.qi > nextFighter.qiMax) {
                    nextFighter.qi = nextFighter.qiMax;
                }
            }
        }

        _owner.removeFighter(fg.currentFighter, true);

        fg.currentFighter = nextFighter;

        _owner.addFighter(fg.currentFighter, team.id);

        return true;
    }

}
