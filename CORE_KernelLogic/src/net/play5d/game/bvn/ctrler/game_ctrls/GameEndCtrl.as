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

package net.play5d.game.bvn.ctrler.game_ctrls {
import flash.utils.getTimer;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.data.vos.GameRunDataVO;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 对局结束演出：KO、平局和续关等待。
 *
 * <p><code>render</code> 返回 <code>true</code> 表示演出结束。<code>initialize</code> 不会清掉平局标记，之前调用过 <code>drawGame</code> 时仍走平局。
 * <code>SHOW_CONTINUE</code> 为 <code>true</code> 时 <code>skip</code> 直接返回。小队或生存模式会按剩余时间给 <code>lastWinner</code> 加体力，<code>lastWinner</code> 为空时抛错。</p>
 *
 * @see KoPresentCtrl
 */
public class GameEndCtrl {

    /**
     * 是否在结束演出里等续关。
     *
     * @default false
     */
    public static var SHOW_CONTINUE:Boolean = false;

    /** @private */
    private var _winner:FighterMain;
    /** @private */
    private var _loser:FighterMain;
    /** @private */
    private var _step:int;
    /** @private */
    private var _isRender:Boolean;
    /** @private */
    private var _holdFrame:int;
    /** @private */
    private var _drawGame:Boolean;
    /** @private KO 影片结束后，观察败者并切胜者镜头 */
    private var _koWatch:Boolean;
    /** @private 跳过启动当帧，与界面下一帧再观察一致 */
    private var _koArm:int;
    /** @private 败者已经进入击飞 */
    private var _slowOn:Boolean;
    /** @private 击飞开始时间 */
    private var _flyTimer:int;
    /** @private 切胜者镜头前的等待帧 */
    private var _winnerDelay:int;

    /**
     * 开始胜负演出，并禁止再掉体力。
     *
     * @param winner 胜者。
     * @param loser 败者。
     * @example
     * <listing version="3.0">
     * end.initialize(winner, loser);
     * </listing>
     */
    public function initialize(winner:FighterMain, loser:FighterMain):void {
        GameCtrl.I.gameRunData.setAllowLoseHP(false);

        _winner   = winner;
        _loser    = loser;
        _step     = 0;
        _isRender = true;
    }

    /**
     * 改为平局演出，并禁止再掉体力。
     *
     * @example
     * <listing version="3.0">
     * end.drawGame();
     * </listing>
     */
    public function drawGame():void {

        GameCtrl.I.gameRunData.setAllowLoseHP(false);

        _drawGame = true;
        _step     = 0;
        _isRender = true;
    }

    /**
     * 丢掉胜负双方的引用。
     *
     * <p>演出还在跑时，之后的 <code>render</code> 可能抛错。</p>
     */
    public function destroy():void {
        _winner = null;
        _loser  = null;
    }

    /**
     * 推进结束演出。
     *
     * @return 演出结束时为 <code>true</code>。还在等待或尚未开始时为 <code>false</code>。
     */
    public function render():Boolean {

        if (!_isRender) {
            return false;
        }

        watchKo();

        if (_holdFrame-- > 0) {
            return false;
        }

        if (_drawGame) {
            return renderDrawGame();
        }
        return renderEND();

    }

    /**
     * 把当前等待帧清掉。
     *
     * <p>只在步骤为 2 且没在等续关时生效。</p>
     *
     * @example
     * <listing version="3.0">
     * end.skip();
     * </listing>
     */
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
                GameUI.I.showContinue(function ():void {
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
            if (!GameCtrl.I.gameRunData.isTimerOver) {
                KoPresentCtrl.focus(_loser);
                KoPresentCtrl.hold();
            }
            GameUI.I.getUI().showEnd(function ():void {
                _holdFrame = 0;
            }, {
                winner        : _winner,
                loser         : _loser,
                onKoClip      : function ():void {
                    beginKoWatch(true);
                },
                onTimeOverClip: function ():void {
                    beginKoWatch(false);
                }
            });
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
                GameUI.I.showContinue(function ():void {
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
            GameUI.I.getUI().fadeOut(false);
            return true;
            break;
        }
        return false;
    }

    private function beginKoWatch(applySlow:Boolean):void {
        _koWatch     = true;
        _koArm       = 1;
        _slowOn      = false;
        _winnerDelay = 0;
        if (applySlow) {
            KoPresentCtrl.release();
            KoPresentCtrl.slow(2, 0);
        }
        else {
            _winnerDelay = GameConfig.FPS_GAME;
        }
    }

    private function watchKo():void {
        if (!_koWatch) {
            return;
        }
        if (_koArm > 0) {
            _koArm--;
            return;
        }
        if (_winnerDelay > 0) {
            _winnerDelay--;
            if (_winnerDelay <= 0) {
                showKoWinner();
            }
            return;
        }
        if (!_loser) {
            return;
        }

        if (_loser.actionState == FighterActionState.HURT_FLYING) {
            if (!_slowOn) {
                _slowOn   = true;
                _flyTimer = getTimer();
            }
        }
        if (_loser.actionState == FighterActionState.DEAD) {
            if (_slowOn) {
                if (getTimer() - _flyTimer < 2000) {
                    _winnerDelay = 2 * GameConfig.FPS_GAME;
                }
                else {
                    _winnerDelay = GameConfig.FPS_GAME;
                }
            }
            else {
                _winnerDelay = 2 * GameConfig.FPS_GAME;
            }
            KoPresentCtrl.clearSlow();
        }
    }

    private function showKoWinner():void {
        _koWatch = false;
        KoPresentCtrl.focus(_winner);
        GameUI.I.showKoWinner(_winner);
        _holdFrame = 0;
    }

}
}
