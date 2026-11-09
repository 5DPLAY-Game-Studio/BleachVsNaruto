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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.StateCtrl;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 对局开场：1v1 登场、下一回合和无双开场 UI。
 *
 * <p><code>render</code> 返回 <code>true</code> 表示这一段开场结束。1v1 在返回 <code>true</code> 的同时清掉双方引用，但不会关掉 1v1 标记，下一次 <code>render</code> 会在读动作状态时抛错。
 * <code>introTeamId</code> 为 1 或 2 时只播该侧登场，其它值两边都播，背景音乐却用 P2 的。
 * <code>skip</code> 只在 1v1 且还没到开场 UI 那一步时生效。</p>
 *
 * @see GameCtrl
 */
public class GameStartCtrl {

    /**
     * 绑上对局场景。
     *
     * @param state 对局场景。
     * @example
     * <listing version="3.0">
     * var start:GameStartCtrl = new GameStartCtrl(stage);
     * </listing>
     */
    public function GameStartCtrl(state:GameStage) {
        _state = state;
    }
    /** @private */
    private var _state:GameStage;
    /** @private */
    private var _p1:FighterMain;
    /** @private */
    private var _p2:FighterMain;
    /** @private */
    private var _isStart1v1:Boolean;
    /** @private */
    private var _isStartNextRound:Boolean;
    /** @private */
    private var _isStartMusou:Boolean;
    /** @private */
    private var _step:int;
    /** @private */
    private var _holdFrame:int;
    /** @private */
    private var _uiPlaying:Boolean;
    /** @private 登场侧。-1 表示两边都播 */
    private var _introTeamId:int     = -1;
    /** @private */
    private var _musouFinish:Boolean = false;

    /**
     * 丢掉场景和双方引用。
     *
     * <p>开场标记还在时，之后的 <code>render</code> 会抛错。</p>
     */
    public function destroy():void {
        _p1    = null;
        _p2    = null;
        _state = null;
    }

    /**
     * 推进当前开场。
     *
     * @return 这一段开场结束时为 <code>true</code>。三种开场都没开始时一直是 <code>false</code>。
     */
    public function render():Boolean {
        if (_isStart1v1) {
            return renderStart1v1();
        }
        if (_isStartNextRound) {
            return renderNextRound();
        }
        if (_isStartMusou) {
            return renderStartMusou();
        }
        return false;
    }

    /**
     * 开始 1v1 登场。
     *
     * @param p1 左侧角色。
     * @param p2 右侧角色。
     * @param introTeamId 1 或 2 只播该侧；其它值两边都播。默认 -1。
     * @example
     * <listing version="3.0">
     * start.start1v1(p1, p2);
     * </listing>
     */
    public function start1v1(p1:FighterMain, p2:FighterMain, introTeamId:int = -1):void {
        _p1          = p1;
        _p2          = p2;
        _isStart1v1  = true;
        _introTeamId = introTeamId;

        switch (introTeamId) {
        case 1:
            SoundCtrl.I.smartPlayGameBGM(p1.data.id);
            break;
        case 2:
            SoundCtrl.I.smartPlayGameBGM(p2.data.id);
            break;
        default:
            SoundCtrl.I.smartPlayGameBGM(p2.data.id);
        }

        preRenderStart();

    }

    /**
     * 开始无双开场 UI。
     *
     * <p>UI 回调之后，下一次 <code>render</code> 返回 <code>true</code>。</p>
     *
     * @example
     * <listing version="3.0">
     * start.startMusou();
     * </listing>
     */
    public function startMusou():void {
        _isStartMusou = true;
        _musouFinish = false;
        GameUI.I.getUI().showStart(function ():void {
            _musouFinish = true;
        });
    }

    /**
     * 开始下一回合的开场 UI。
     *
     * <p>UI 回调把播放标记清掉之后，下一次 <code>render</code> 返回 <code>true</code>。</p>
     *
     * @example
     * <listing version="3.0">
     * start.startNextRound();
     * </listing>
     */
    public function startNextRound():void {
        _isStartNextRound = true;

        _uiPlaying = true;
        StateCtrl.I.transOut(null, true);

        _state.gameUI.getUI().showStart(function ():void {
            _uiPlaying = false;
        });

    }

    /**
     * 跳过 1v1 登场，直接进入开场 UI 之后的等待。
     *
     * <p>已经到开场 UI，或当前不是 1v1 时，什么都不做。</p>
     *
     * @example
     * <listing version="3.0">
     * start.skip();
     * </listing>
     */
    public function skip():void {

        if (_isStart1v1) {
            if (_step < 5) {
                StateCtrl.I.quickTrans();
                _state.cameraResume();
                _uiPlaying = false;
                _step      = 6;
                _state.gameUI.getUI().fadeIn(true);

                _p1.idle();
                _p2.idle();

                _holdFrame = 0.5 * GameConfig.FPS_GAME;
            }
        }

        if (_isStartNextRound) {

        }

    }

    private function renderStartMusou():Boolean {
        return _musouFinish;
    }

    private function preRenderStart():void {
        _step = -1;

        var initStep:int = 0;

        switch (_introTeamId) {
        case -1:
            initStep = 0;
            break;
        case 1:
            _state.cameraFocusOne(_p1.getDisplay());
            initStep = 1;
            break;
        case 2:
            _state.cameraFocusOne(_p2.getDisplay());
            initStep = 2;
            break;

        }

        _state.camera.updateNow();
        StateCtrl.I.transOut(function ():void {
            _step = initStep;
        }, true);
    }

    private function renderStart1v1():Boolean {
        if (_uiPlaying) {
            return false;
        }

        if (_p1.actionState == FighterActionState.KAI_CHANG || _p2.actionState ==
            FighterActionState.KAI_CHANG) {
            return false;
        }

        if (_holdFrame-- > 0) {
            return false;
        }

        switch (_step) {
        case 0:
            if (_introTeamId == -1 || _introTeamId == 1) {
                _state.cameraFocusOne(_p1.getDisplay());
                _holdFrame = 0.5 * GameConfig.FPS_GAME;
                _step      = 1;
            }
            else {
                _step = 2;
            }
            break;
        case 1:
            _p1.sayIntro();
            _holdFrame = 0.3 * GameConfig.FPS_GAME;
            _step      = 2;
            break;
        case 2:
            if (_introTeamId == -1 || _introTeamId == 2) {
                _state.cameraFocusOne(_p2.getDisplay());
                _holdFrame = 0.5 * GameConfig.FPS_GAME;
                _step      = 3;
            }
            else {
                _step = 4;
            }
            break;
        case 3:
            _p2.sayIntro();
            _holdFrame = 0.3 * GameConfig.FPS_GAME;
            _step      = 4;
            break;
        case 4:
            _state.cameraResume();
            _holdFrame = 0.1 * GameConfig.FPS_GAME;
            _step      = 5;
            break;
        case 5:
            //round 1 , ready fight!
            _uiPlaying = true;
            _state.gameUI.getUI().showStart(function ():void {
                _uiPlaying = false;
            });
            _step = 6;
            break;
        case 6:
            _p1 = null;
            _p2 = null;
            return true;
        }

        return false;
    }

    private function renderNextRound():Boolean {
        return _uiPlaying == false;
    }


}
}
