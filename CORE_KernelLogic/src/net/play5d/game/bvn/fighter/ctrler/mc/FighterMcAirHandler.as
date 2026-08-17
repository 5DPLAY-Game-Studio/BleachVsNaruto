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
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.events.FighterEvent;

/**
 * 空中 / 跳跃 / 落地域。
 *
 * @see FighterMcActionCtrl
 */
public class FighterMcAirHandler extends FighterMcActsPart {

    /** @private */
    private var _ghost:FighterMcGhostHandler;
    /** @private */
    private var _floor:FighterMcFloorHandler;
    /** @private 跳跃延时（帧） */
    private var _jumpDelayFrame:int = 0;

    /**
     * 绑定幽步 Handler（空中输入可触发幽步）。
     *
     * @param ghost 幽步域。
     */
    public function bindGhost(ghost:FighterMcGhostHandler):void {
        _ghost = ghost;
    }

    /**
     * 绑定地面 Handler（空中连段复用地面技能入口）。
     *
     * @param floor 地面域。
     */
    public function bindFloor(floor:FighterMcFloorHandler):void {
        _floor = floor;
    }

    public override function destroy():void {
        _ghost = null;
        _floor = null;
        super.destroy();
    }

    /**
     * 落地。
     */
    public function touchFloor():void {

        if (!_fighter.isAlive) {
            return;
        }

//			trace("touchFloor" , _action.touchFloor);

        var act:String = _action.touchFloor;

        if (_isFalling) {
            act ||= FighterSpecialFrame.JUMP_TOUCH_FLOOR;
        }

        if (act == null) {
            return;
        }

//			_action.clearAction();

        var delayParam:Object = act == FighterSpecialFrame.JUMP_TOUCH_FLOOR ? {call: _owner.setAttack, delay: 1} : null;
        _owner.doAction(act, false, delayParam);
        _owner.effectCtrler.touchFloor();

        _action.airHitTimes = _fighter.airHitTimes;
        _action.jumpTimes   = _fighter.jumpTimes;

        _isTouchFloor = true;
        _isFalling    = false;

    }

    /**
     * 正在跳
     */
    public function renderJumpAnimate():void {
        if (_doingAction) {
            return;
        }

        if (_jumpDelayFrame > 0) {
            _jumpDelayFrame--;
            if (_jumpDelayFrame == 0) {
                _isFalling = false;
                _action.jumpTimes--;
                _mc.goFrame(FighterSpecialFrame.JUMP, false);
                _fighter.jump();
                _owner.setAirAllAct();
                if (_fighter.isInAir) {
                    _owner.effectCtrler.jumpAir();
                }
                else {
                    _owner.effectCtrler.jump();
                }
//					_owner.setJumpQuick();
            }
            return;
        }

        if (_mc.getCurrentFrameCount() == 2) {
            _owner.setJumpQuick();
        }

        var vecy:Number = _fighter.getVecY();
        if (_mc.currentFrameName != FighterSpecialFrame.JUMP_ING && vecy > -_fighter.jumpPower * 0.35) {
            _mc.goFrame(FighterSpecialFrame.JUMP_ING, false);
//				_owner.setJump();
            _fighter.setAnimateFrameOut(_owner.setJump, 5);
        }

        if (vecy >= 0) {
            _action.isJumping = false;
            _isFalling        = true;
        }
    }

    /**
     * 空中动作输入与状态。
     */
    public function renderAirAction():void {

        if (!_fighter.isAlive) {
            return;
        }

        if (!_action.isJumping) {
            fall();
        }

        _isTouchFloor = false;

        if (_actionLogic == null || !_actionLogic.enabled()) {
            return;
        }

        if (_actionLogic.attackAIR()) {
            doAirAttack(_action.attackAIR);
        }
        if (_actionLogic.skillAIR()) {
            doAirSkill(_action.skillAIR);
        }
        if (_actionLogic.bishaAIR()) {
            doAirBisha(_action.bishaAIR, _action.bishaAIRQi);
        }
        if (_actionLogic.jump()) {
            doAirJump(_action.jump);
        }
        if (_actionLogic.jumpQuick()) {
            doAirJump(_action.jumpQuick);
        }

        //仅限连招使用
        if (FighterActionState.isAttacking(_fighter.actionState)) {
            if (_actionLogic.bishaSUPER()) {
                _floor.doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true, FighterInputCmd.BISHA_SUPER);
            }
            if (_actionLogic.bishaUP()) {
                _floor.doBisha(_action.bishaUP, _action.bishaUPQi, false, FighterInputCmd.BISHA_UP);
            }
            if (_actionLogic.bisha()) {
                _floor.doBisha(_action.bisha, _action.bishaQi, false, FighterInputCmd.BISHA);
            }

            if (_actionLogic.skill2()) {
                _floor.doSkill(_action.skill2, FighterInputCmd.SKILL_2);
            }
            if (_actionLogic.skill1()) {
                _floor.doSkill(_action.skill1, FighterInputCmd.SKILL_1);
            }

            if (_actionLogic.zhao3()) {
                _floor.doSkill(_action.zhao3, FighterInputCmd.ZHAO_3);
            }
            if (_actionLogic.zhao2()) {
                _floor.doSkill(_action.zhao2, FighterInputCmd.ZHAO_2);
            }

            if (_actionLogic.attack()) {
                _floor.doAttack(_action.attack);
            }

            if (_actionLogic.zhao1()) {
                _floor.doSkill(_action.zhao1, FighterInputCmd.ZHAO_1);
            }
        }

        if (_actionLogic.dash()) {
            doDashAir(_action.dash);
        }

        if (_actionLogic.airMove()) {
            doAirMove();
        }
        if (_actionLogic.ghostJump()) {
            _ghost.doGhostJump();
        }
        if (_actionLogic.ghostJumpDown()) {
            _ghost.doGhostJumpDown();
        }
    }

    /**
     * 改变状态为：下落
     */
    public function fall():void {
        if (_isFalling) {
            return;
        }
        if (_doingAction) {
            return;
        }

        _action.clearState();
        _action.clearAction();

        _owner.setAirAllAct();
        _owner.setJump();

        _isFalling      = true;
        _doingAirAction = null;
        _isTouchFloor   = false;
        _hurt.clearDefense();

        _fighter.setVecX(0);

        _owner.setTouchFloor(FighterSpecialFrame.JUMP_TOUCH_FLOOR, true);

        _mc.goFrame(FighterSpecialFrame.JUMP_DOWN, false);
    }

    /**
     * 执行空中移动
     */
    public function doAirMove():void {
        if (_actionCtrler.moveLEFT()) {
            _fighter.move(-_fighter.speed);
        }
        if (_actionCtrler.moveRIGHT()) {
            _fighter.move(_fighter.speed);
        }
    }

    private function doDashAir(action:String):void {
        if (_action.jumpTimes < 1) {
            return;
        }
        if (!_fighter.hasEnergy(30, true)) {
            return;
        }
        _fighter.useEnergy(30);

        _owner.doAction(action, false, null, FighterInputCmd.DASH);
        _fighter.actionState  = FighterActionState.DASH_ING;
        _fighter.isAllowBeHit = false;
        _owner.isApplyG(false);
        _action.jumpTimes = 0;
    }

    /**
     * 执行跳
     */
    public function doJump(action:String):void {
        if (_action.jumpTimes <= 0) {
            return;
        }

        _action.clearAction();
        _action.clearState();
        _doingAction    = null;
        _doingAirAction = null;

        _mc.goFrame(FighterSpecialFrame.JUMP_START, false);
        _jumpDelayFrame      = GameConfig.JUMP_DELAY_FRAME;
        _action.isJumping    = true;
        _fighter.actionState = FighterActionState.JUMP_ING;

        var jumpEvt:FighterEvent = new FighterEvent(FighterEvent.DO_ACTION);
        jumpEvt.params           = {action: FighterSpecialFrame.JUMP, input: FighterInputCmd.JUMP};
        _fighter.dispatchEvent(jumpEvt);
    }

    /**
     * 执行从空中的板上跳下
     */
    public function doJumpDown(acion:String):void {
        if (_fighter.isTouchBottom) {
            return;
        }
        _action.clear();
        _action.jumpTimes = 0;
        _fighter.setVecY(GameConfig.NO_TOUCH_BAN_ON_VECY);
        _fighter.setDamping(0, 1);
        _fighter.y += 1;
        _hurt.clearDefense();
        _mc.goFrame(acion, false);
        _owner.setTouchFloor();
    }

    /**
     * 执行空中二段跳
     */
    public function doAirJump(action:String):void {
        if (_action.jumpTimes <= 0) {
            return;
        }

        _action.clearAction();
        _action.clearState();
        _doingAction    = null;
        _doingAirAction = null;

        _jumpDelayFrame      = GameConfig.JUMP_DELAY_FRAME_AIR;
        _action.isJumping    = true;
        _fighter.actionState = FighterActionState.JUMP_ING;

        var airJumpEvt:FighterEvent = new FighterEvent(FighterEvent.DO_ACTION);
        airJumpEvt.params           = {action: FighterSpecialFrame.JUMP, input: FighterInputCmd.JUMP};
        _fighter.dispatchEvent(airJumpEvt);
    }

    /**
     * 执行空中必杀
     */
    public function doAirAttack(action:String):void {
        if (_doingAction == null && _action.airHitTimes <= 0) {
            return;
        }

        _fighter.addDamping(0, 3);

        _action.airHitTimes--;
        _action.jumpTimes = 0;

        _owner.doAction(action, true, null, FighterInputCmd.ATTACK_AIR);

        _fighter.actionState = FighterActionState.ATTACK_ING;
    }

    /**
     * 执行空中技能
     */
    public function doAirSkill(action:String):void {
        if (_doingAction == null && _action.airHitTimes <= 0) {
            return;
        }

        var inputText:String = FighterInputCmd.SKILL_AIR;
        if (_action.isJumping) {
            var act:String = null;
            if (_actionCtrler.zhao3()) {
                act = FighterSpecialFrame.SKILL_AIR_W;
            }
            if (_actionCtrler.zhao2()) {
                act = FighterSpecialFrame.SKILL_AIR_S;
            }
            if (act && _mc.checkFrame(act)) {
                action    = act;
                inputText = (act == FighterSpecialFrame.SKILL_AIR_W) ? FighterInputCmd.SKILL_AIR_W : FighterInputCmd.SKILL_AIR_S;
            }
        }

        //			fighter.setVelocity(0,0);

        _action.airHitTimes = 0;
        _action.jumpTimes   = 0;

        _owner.doAction(action, true, null, inputText);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * 执行空中必杀
     */
    public function doAirBisha(action:String, qi:int):void {
        if (_doingAction == null && _action.airHitTimes <= 0) {
            return;
        }

        if (!_fighter.useQi(qi)) {
            return;
        }
        _fighter.actionState = FighterActionState.BISHA_ING;

        _action.airHitTimes = 0;
        _owner.doAction(action, true, null, FighterInputCmd.BISHA_AIR);
    }

}
}
