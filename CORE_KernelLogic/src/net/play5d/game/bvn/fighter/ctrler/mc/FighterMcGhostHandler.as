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

package net.play5d.game.bvn.fighter.ctrler.mc {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;

/**
 * 幽步域。
 *
 * @see FighterMcActionCtrl
 */
public class FighterMcGhostHandler extends FighterMcActsPart {

    /** @private */
    private var _ghostStepIng:Boolean;
    /** @private */
    private var _ghostStepFrame:int;
    /** @private */
    private var _ghostType:int = 0;

    /**
     * 是否处于幽步中。
     */
    public function get ghostStepIng():Boolean {
        return _ghostStepIng;
    }

    public override function destroy():void {
        super.destroy();
    }

    public function doGhostStep():void {
        if (startGhostStep()) {
            _owner.move(8, 0);
            _mc.goFrame(FighterSpecialFrame.MOVE, true);
            _ghostType = 0;
            _owner.dispatchTrainingInput(FighterInputCmd.GHOST_DASH_S);
        }
    }

    public function doGhostJump():void {
        if (startGhostStep()) {
            _owner.move(0, -12);
            _owner.damping(0, 0.1);
            _mc.goFrame(FighterSpecialFrame.JUMP, false);
            _action.jumpTimes--;
            _ghostType = 1;
            _owner.dispatchTrainingInput(FighterInputCmd.GHOST_DASH_W);
        }
    }

    public function doGhostJumpDown():void {
        if (startGhostStep()) {
            _owner.move(0, 15);
            _mc.goFrame(FighterSpecialFrame.JUMP_DOWN, false);
            _ghostType = 2;
            _owner.dispatchTrainingInput(FighterInputCmd.GHOST_DASH_S);
        }
    }

    private function startGhostStep():Boolean {
        if (_fighter.qi < 60) {
            return false;
        }
        if (!_fighter.hasEnergy(80, true)) {
            return false;
        }

        _fighter.useQi(60);
        _fighter.useEnergy(80);

        _fighter.getCtrler().setDirectToTarget();

        _ghostStepIng         = true;
        _ghostStepFrame       = GameConfig.FPS_ANIMATE * 0.4;
        _fighter.isAllowBeHit = false;
        _fighter.isCross      = true;
        _owner.effectCtrler.ghostStep();

        return true;
    }

    /**
     * 幽步
     */
    public function renderGhostStep():void {

        if (_ghostStepFrame-- <= 0) {
            if (_ghostType == 1) {
                var vecy:Number   = _fighter.getVecY();
                _action.isJumping = false;

                endGhostStep();

                _fighter.setVelocity(0, vecy);
                _fighter.setDamping(0, -vecy / 10);
                _owner.setAirMove(true);
                return;
            }
            endGhostStep();
        }

        if (_ghostType == 2) {
            if (GameLogic.isTouchBottomFloor(_fighter)) {
                endGhostStep();
            }
        }
    }

    private function endGhostStep():void {
        _ghostStepIng = false;
        _owner.effectCtrler.endGhostStep();
        _fighter.getCtrler().setDirectToTarget();
        _owner.idle();
    }

}
}
