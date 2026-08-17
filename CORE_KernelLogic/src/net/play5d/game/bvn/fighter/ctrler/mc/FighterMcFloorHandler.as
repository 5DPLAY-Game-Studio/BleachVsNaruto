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
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 地面输入 / 移动 / 技能 / 卍解域。
 *
 * @see FighterMcActionCtrl
 */
public class FighterMcFloorHandler extends FighterMcActsPart {

    /** @private */
    private var _air:FighterMcAirHandler;
    /** @private */
    private var _ghost:FighterMcGhostHandler;

    /**
     * 绑定空中与幽步 Handler。
     *
     * @param air 空中域。
     * @param ghost 幽步域。
     */
    public function bindPeers(air:FighterMcAirHandler, ghost:FighterMcGhostHandler):void {
        _air   = air;
        _ghost = ghost;
    }

    public override function destroy():void {
        _air   = null;
        _ghost = null;
        super.destroy();
    }

    /**
     * 特殊技（援助）输入。
     */
    public function renderSpecial():void {
//			if(_fighter.actionState != FighterActionState.NORNAL && _fighter.actionState !=
// FighterActionState.DEFENSE_ING) return;

//			if(_actionCtrler.specailSkill()){
//				if(_fighter.fzqi >= _fighter.fzqiMax){
//					_fighter.fzqi = 0;
//					FighterEventDispatcher.dispatchEvent(_fighter,FighterEvent.DO_SPECIAL);
//				}
//			}

        if (_actionLogic.specailSkill()) {
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DO_SPECIAL);
        }

    }

    /**
     * 地面动作输入与状态。
     */
    public function renderFloorAction():void {
        if (!_fighter.isAlive) {
            return;
        }

        if (!_isTouchFloor) {
            _air.touchFloor();
        }

        if (_actionLogic == null || !_actionLogic.enabled()) {
            if (_mc.currentFrameName == FighterSpecialFrame.MOVE || _mc.currentFrameName == FighterSpecialFrame.DEFENSE) {
                _owner.idle();
            }
            return;
        }

        renderSpecial();

        if (_actionLogic.catch1()) {
            doCatch(_action.catch1, FighterInputCmd.ATTACK);
        }
        if (_actionLogic.catch2()) {
            doCatch(_action.catch2, FighterInputCmd.ZHAO_1);
        }

        if (_actionLogic.bishaSUPER()) {
            doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true, FighterInputCmd.BISHA_SUPER);
        }
        if (_actionLogic.bishaUP()) {
            doBisha(_action.bishaUP, _action.bishaUPQi, false, FighterInputCmd.BISHA_UP);
        }
        if (_actionLogic.bisha()) {
            doBisha(_action.bisha, _action.bishaQi, false, FighterInputCmd.BISHA);
        }

        if (_actionLogic.skill2()) {
            doSkill(_action.skill2, FighterInputCmd.SKILL_2);
        }
        if (_actionLogic.skill1()) {
            doSkill(_action.skill1, FighterInputCmd.SKILL_1);
        }

        if (_actionLogic.zhao3()) {
            doSkill(_action.zhao3, FighterInputCmd.ZHAO_3);
        }
        if (_actionLogic.zhao2()) {
            doSkill(_action.zhao2, FighterInputCmd.ZHAO_2);
        }

        if (_actionLogic.attack()) {
            doAttack(_action.attack);
        }

        if (_actionLogic.zhao1()) {
            doSkill(_action.zhao1, FighterInputCmd.ZHAO_1);
        }

        if (_actionLogic.defense()) {
            _hurt.doDefense();
        }

        if (_actionLogic.dash()) {
            doDash(_action.dash);
        }

        if (_actionLogic.moveLEFT()) {
            doMove(_action.moveLeft, -1);
        }
        if (_actionLogic.moveRIGHT()) {
            doMove(_action.moveRight, 1);
        }

        if (_actionLogic.jump()) {
            _air.doJump(_action.jump);
        }
        if (_actionLogic.jumpDown()) {
            _air.doJumpDown(_action.jumpDown);
        }

        if (_action.isMoving) {
            renderMoving();
        }
        if (_action.isDefensing) {
            _hurt.renderDefense();
        }

        if (_actionLogic.ghostStep()) {
            _ghost.doGhostStep();
        }
        if (_actionLogic.ghostJump()) {
            _ghost.doGhostJump();
        }

        //仅限连招使用
        if (FighterActionState.isAttacking(_fighter.actionState)) {
            if (_actionLogic.attackAIR()) {
                _air.doAirAttack(_action.attackAIR);
            }
            if (_actionLogic.skillAIR()) {
                _air.doAirSkill(_action.skillAIR);
            }
            if (_actionLogic.bishaAIR()) {
                _air.doAirBisha(_action.bishaAIR, _action.bishaAIRQi);
            }
        }

    }

    /**
     * 卍解输入。
     *
     * @return 是否已消耗本帧输入。
     */
    public function renderWanKaiCtrl():Boolean {
        if (!_actionLogic || !_actionLogic.enabled()) {
            return false;
        }

        if (_actionLogic.waiKai()) {
            return checkDoWankai(_action.waiKai, FighterSpecialFrame.BANKAI, FighterInputCmd.BANKAI);
        }
        if (_actionLogic.waiKaiW()) {
            return checkDoWankai(_action.waiKaiW, FighterSpecialFrame.BANKAI_W, FighterInputCmd.BANKAI_W);
        }
        if (_actionLogic.waiKaiS()) {
            return checkDoWankai(_action.waiKaiS, FighterSpecialFrame.BANKAI_S, FighterInputCmd.BANKAI_S);
        }

        return false;
    }

    private function checkDoWankai(action:String, attackingAct:String, inputText:String):Boolean {
        if (action) {
            doWaiKaiAction(action, inputText);
            return true;
        }

        if (_doingAction == FighterSpecialFrame.ATTACK) {
            if (_rt.doActionFrame < 2) {
                doWaiKaiAction(attackingAct, inputText);
                return true;
            }
        }

        return false;
    }

    private function setMoveAction():void {
        _action.clearAction();

        _action.isMoving = true;

        _owner.setMove();
        _owner.setAttack();

        _owner.setZhao1();
//			_owner.setZhao2();
        _owner.setZhao3();

//			_owner.setSkill1();
        _owner.setSkill2();

        _owner.setJump();
        _owner.setDash();
        _owner.setBisha();
        _owner.setBishaUP();
//			_owner.setBishaSUPER();

        _owner.setDefense();

        _owner.setCatch1();
        _owner.setCatch2();

    }

    /**
     * 正在移动
     */
    public function renderMoving():void {
        if (_actionCtrler.moveLEFT()) {
            _fighter.direct = -1;
            _owner.move(_fighter.speed);
        }
        else if (_actionCtrler.moveRIGHT()) {
            _fighter.direct = 1;
            _owner.move(_fighter.speed);
        }
        else {
            _owner.idle();
        }
    }

    /**
     * 执行移动
     */
    public function doMove(action:String, direct:int = 1):void {
        if (_action.isMoving) {
            return;
        }
//			_mc.goFrame(action,false);
        _mc.goFrame(action, true);
        _fighter.actionState = FighterActionState.NORMAL;
        setMoveAction();
    }

    /**
     * 执行冲刺
     */
    public function doDash(action:String):void {

        if (!_fighter.hasEnergy(20, true)) {
            return;
        }
        _fighter.useEnergy(20);

        if (_actionCtrler.moveLEFT()) {
            _fighter.direct = -1;
        }
        if (_actionCtrler.moveRIGHT()) {
            _fighter.direct = 1;
        }
        _owner.doAction(action, false, null, FighterInputCmd.DASH);
        _fighter.actionState  = FighterActionState.DASH_ING;
        _fighter.isAllowBeHit = false;
        _owner.isApplyG(false);
    }

    /**
     * 执行攻击
     */
    public function doAttack(action:String):void {
        _owner.doAction(action, false, null, FighterInputCmd.ATTACK);
        _fighter.actionState = FighterActionState.ATTACK_ING;
    }

    /**
     * 执行技能
     * @param inputText 练习模式输入历史指令（如 WJ / SJ）
     */
    public function doSkill(action:String, inputText:String):void {
        _owner.doAction(action, false, null, inputText);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * 执行摔技
     * @param btnLetter 按键字母 J 或 U，左右由当前方向键决定
     */
    public function doCatch(action:String, btnLetter:String):void {
        if (!allowCatch()) {
            return;
        }
//			if(!_action.CDOK("catch")) return;
//			_action.setCD("catch" , 5000);

        _owner.doAction(action, false, null, getCatchInputSideLetter() + btnLetter);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * @private 摔技左右方向字母（绝对左右键）。
     */
    public function getCatchInputSideLetter():String {
        if (_actionCtrler.moveRIGHT() && !_actionCtrler.moveLEFT()) {
            return FighterInputCmd.RIGHT;
        }
        if (_actionCtrler.moveLEFT() && !_actionCtrler.moveRIGHT()) {
            return FighterInputCmd.LEFT;
        }
        if (_actionCtrler.moveRIGHT()) {
            return FighterInputCmd.RIGHT;
        }
        if (_actionCtrler.moveLEFT()) {
            return FighterInputCmd.LEFT;
        }
        if (_fighter && _fighter.direct > 0) {
            return FighterInputCmd.RIGHT;
        }

        return FighterInputCmd.LEFT;
    }

    /**
     * 执行必杀
     * @param inputText 练习模式输入历史指令（如 I / WI / SI）
     */
    public function doBisha(action:String, qi:int, isSuper:Boolean = false, inputText:String = null):void {
        if (!_fighter.useQi(qi)) {
            return;
        }

        _fighter.actionState = isSuper ? FighterActionState.BISHA_SUPER_ING : FighterActionState.BISHA_ING;

        _owner.doAction(action, false, null, inputText);
    }

    /**
     * 执行万解
     * @param inputText 练习模式输入历史指令（如 JK / WJK / SJK）
     */
    public function doWaiKaiAction(action:String, inputText:String):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        if (!_fighter.useQi(300)) {
            return;
        }
        ;
        _fighter.actionState = FighterActionState.WAN_KAI_ING;
        _owner.doAction(action, false, null, inputText);
        _fighter.isAllowBeHit = false;
    }

    private function allowCatch():Boolean {
        var target:IGameSprite = _fighter.getCurrentTarget();
        if (!target) {
            return false;
        }

        if (target is FighterMain) {
            if ((
                        target as FighterMain
                ).actionState == FighterActionState.HURT_ING) {
                return false;
            }
        }

        var targetBody:Rectangle = target.getBodyArea();
        var selfBody:Rectangle   = _fighter.getBodyArea();
        if (!targetBody || !selfBody) {
            return false;
        }

        var disX:Number;
        var disY:Number = Math.abs(_fighter.y - target.y);

        if (selfBody.x < targetBody.x) {
            if (_fighter.direct < 0) {
                return false;
            }
            disX = targetBody.x - (
                    selfBody.x + selfBody.width
            );
        }
        else {
            if (_fighter.direct > 0) {
                return false;
            }
            disX = selfBody.x - (
                    targetBody.x + targetBody.width
            );
        }

        return disX < 2 && disY < 1;
    }

}
}
