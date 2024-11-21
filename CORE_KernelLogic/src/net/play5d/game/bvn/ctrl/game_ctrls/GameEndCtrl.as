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

package net.play5d.game.bvn.ctrl.game_ctrls {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrl.StateCtrl;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.GameRunDataVO;
import net.play5d.game.bvn.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.fight.FightUI;

public class GameEndCtrl {
    include '_INCLUDE_.as';

    public static var SHOW_CONTINUE:Boolean = false;

    public function GameEndCtrl() {
    }
    private var _winner:FighterMain;
    private var _loser:FighterMain;
    private var _step:int;
    private var _isRender:Boolean;
    private var _holdFrame:int;
    private var _drawGame:Boolean;

    public function initlize(winner:FighterMain, loser:FighterMain):void {
        GameCtrl.I.gameRunData.setAllowLoseHP(false);

        _winner   = winner;
        _loser    = loser;
        _step     = 0;
        _isRender = true;
    }

    public function drawGame():void {

        GameCtrl.I.gameRunData.setAllowLoseHP(false);

        _drawGame = true;
        _step     = 0;
        _isRender = true;
    }

    public function destory():void {
        _winner = null;
        _loser  = null;
    }

    public function render():Boolean {

        if (!_isRender) {
            return false;
        }

        if (_holdFrame-- > 0) {
            return false;
        }

        if (_drawGame) {
            return renderDrawGame();
        }
        return renderEND();

    }

    public function skip():void {
        if (SHOW_CONTINUE) {
            return;
        }

        if (_step == 2) {
            _holdFrame = 0;
        }
    }

    private function renderDrawGame():Boolean {
        switch (_step) {
        case 0:
            GameUI.I.getUI().showEnd(function ():void {
                _holdFrame = 0;
            }, {drawGame: true});

            _step      = 1;
            _holdFrame = 10 * GameConfig.FPS_GAME;
            break;
        case 1:
            _step      = 2;
            _holdFrame = 1 * GameConfig.FPS_GAME;

            if (SHOW_CONTINUE) {
                _holdFrame = 10 * 60 * GameConfig.FPS_GAME;
                (
                        GameUI.I.getUI() as FightUI
                ).showContinue(function ():void {
                    _holdFrame = 0;
                });
            }
            break;
        case 2:
            //战斗结束
            _isRender = false;
            GameUI.I.getUI().clearStartAndEnd();
            return true;
            break;
        }

        return false;
    }

    private function renderEND():Boolean {
        switch (_step) {
        case 0:
            GameUI.I.getUI().showEnd(function ():void {
                _holdFrame = 0;
            }, {winner: _winner, loser: _loser});
            _step      = 1;
            _holdFrame = 10 * GameConfig.FPS_GAME;
            break;
        case 1:

            if (!FighterActionState.isAllowWinState(_winner.actionState)) {
                return false;
            }

            _winner.win();
            _holdFrame = 3 * GameConfig.FPS_GAME;
            _step      = 2;

            var rundata:GameRunDataVO = GameCtrl.I.gameRunData;
            var winner:FighterMain    = rundata.lastWinner;

            if (GameMode.isTeamMode() || GameMode.currentMode == GameMode.SURVIVOR) {
                var timeRate:Number = rundata.gameTime == -1 ? 1 : rundata.gameTime / rundata.gameTimeMax;
                var addHPMax:int    = winner.hpMax * 0.2;
                var addHP:int       = addHPMax * timeRate;
                if (addHP < winner.hpMax * 0.05) {
                    addHP = winner.hpMax * 0.05;
                }
                winner.hp += addHP;
            }

            rundata.lastWinnerHp = winner.hp;


            if (SHOW_CONTINUE) {
                _holdFrame = 10 * 60 * GameConfig.FPS_GAME;
                (
                        GameUI.I.getUI() as FightUI
                ).showContinue(function ():void {
                    _holdFrame = 0;
                });
            }

            break;
        case 2:
            //战斗结束
            _step = 22;

            _winner = null;
            _loser  = null;

            StateCtrl.I.transIn(function ():void {
                _step = 3;
            }, false);

            break;
        case 3:
            _isRender = false;
            GameUI.I.getUI().clearStartAndEnd();
            GameUI.I.getUI().fadOut(false);
            return true;
            break;
        }
        return false;
    }


}
}
