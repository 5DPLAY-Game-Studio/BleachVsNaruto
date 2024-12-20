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
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.ui.GameUI;

/**
 * 游戏开场控制
 */
public class GameStartCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function GameStartCtrl(state:GameStage) {
        _state = state;
    }
    private var _state:GameStage;
    private var _p1:FighterMain;
    private var _p2:FighterMain;
    private var _isStart1v1:Boolean;
    private var _isStartNextRound:Boolean;
    private var _isStartMosou:Boolean;
    private var _step:int;
    private var _holdFrame:int;
    private var _uiPlaying:Boolean;
    private var _introTeamId:int = -1; //-1=both
    private var _mousouFinish:Boolean = false;

    public function destory():void {
        _p1    = null;
        _p2    = null;
        _state = null;
    }

    public function render():Boolean {
        if (_isStart1v1) {
            return renderStart1v1();
        }
        if (_isStartNextRound) {
            return renderNextRound();
        }
        if (_isStartMosou) {
            return renderStartMosou();
        }
        return false;
    }

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

    public function startMosou():void {
        _isStartMosou = true;
        _mousouFinish = false;
        GameUI.I.getUI().showStart(function ():void {
            _mousouFinish = true;
        });
    }

    public function startNextRound():void {
        _isStartNextRound = true;

        _uiPlaying = true;
        StateCtrl.I.transOut(null, true);

        _state.gameUI.getUI().showStart(function ():void {
            _uiPlaying = false;
        });

    }

    public function skip():void {

        if (_isStart1v1) {
            if (_step < 5) {
                StateCtrl.I.quickTrans();
                _state.cameraResume();
                _uiPlaying = false;
                _step      = 6;
                _state.gameUI.getUI().fadIn(true);

                _p1.idle();
                _p2.idle();

                _holdFrame = 0.5 * GameConfig.FPS_GAME;
            }
        }

        if (_isStartNextRound) {

        }

    }

    private function renderStartMosou():Boolean {
        return _mousouFinish;
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
            //					trace("round 1 , ready fight!");
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
