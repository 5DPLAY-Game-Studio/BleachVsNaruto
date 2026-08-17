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

package net.play5d.game.bvn.fighter.ctrler {
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.vos.MoveTargetParamVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 动作渲染域：落地 / 空中输入、跳跃、移动目标、幽步。
 *
 * <p><code>FighterMcCtrler</code> 仍为时间轴门面；本类承接主动作状态机。</p>
 *
 * @see FighterMcCtrler
 */
public class FighterMcActionCtrl {

    /** @private */
    private var _owner:FighterMcCtrler;
    /** @private */
    private var _rt:FighterMcRuntime;
    /** @private */
    private var _hurt:FighterMcHurtCtrl;

    /** @private 跳跃延时（帧） */
    private var _jumpDelayFrame:int = 0;
    /** @private 执行动作的帧数 */
    private var _doActionFrame:int;
    /** @private */
    private var _moveTargetParam:MoveTargetParamVO;
    /** @private */
    private var _ghostStepIng:Boolean;
    /** @private */
    private var _ghostStepFrame:int;
    /** @private */
    private var _autoDirectFrame:int;
    /** @private */
    private var _ghostType:int = 0;

    /**
     * 绑定门面。
     *
     * @param owner <code>FighterMcCtrler</code> 门面。
     * @param rt 共享运行时状态。
     * @param hurt 受击/防御域。
     * @example
     * <listing version="3.0">
     * actionCtrl.bind(mcCtrler, runtime, hurtCtrl);
     * </listing>
     */
    public function bind(owner:FighterMcCtrler, rt:FighterMcRuntime, hurt:FighterMcHurtCtrl):void {
        _owner = owner;
        _rt    = rt;
        _hurt  = hurt;
    }

    /**
     * 释放引用。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.destroy();
     * </listing>
     */
    public function destroy():void {
        _moveTargetParam = null;
        _owner           = null;
        _rt              = null;
        _hurt            = null;
    }

    /**
     * 是否处于幽步中。
     */
    public function get ghostStepIng():Boolean {
        return _ghostStepIng;
    }

    /**
     * 是否正在跟随目标位移。
     */
    public function get hasMoveTarget():Boolean {
        return _moveTargetParam != null;
    }

    /**
     * 设定或清除攻击目标位移。
     *
     * @param params 位移参数；为 <code>null</code> 时清除。
     * @example
     * <listing version="3.0">
     * actionCtrl.setMoveTarget({x:10, y:0});
     * </listing>
     */
    public function setMoveTarget(params:Object = null):void {
        if (!params) {
            if (_moveTargetParam) {
                _moveTargetParam.clear();
            }
            _moveTargetParam = null;
            return;
        }
        _moveTargetParam = new MoveTargetParamVO(params);
        _moveTargetParam.setTarget(_fighter.getCurrentTarget());
    }

    /**
     * 清除移动目标（endAct 等）。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.clearMoveTarget();
     * </listing>
     */
    public function clearMoveTarget():void {
        _moveTargetParam = null;
    }

    /**
     * idle 时重置自动朝向计数。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.resetAutoDirect();
     * </listing>
     */
    public function resetAutoDirect():void {
        _autoDirectFrame = 0;
    }

    /**
     * doAction 开始时重置动作帧计数。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.resetDoActionFrame();
     * </listing>
     */
    public function resetDoActionFrame():void {
        _doActionFrame = 0;
    }

    /**
     * 动画帧：推进当前动作帧计数。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.tickDoActionFrame();
     * </listing>
     */
    public function tickDoActionFrame():void {
        if (_doingAction) {
            _doActionFrame++;
        }
    }

    /**
     * 动画帧：idle 自动朝向。
     *
     * @example
     * <listing version="3.0">
     * actionCtrl.tickAutoDirect();
     * </listing>
     */
    public function tickAutoDirect():void {
        if (_mc && _mc.currentFrameName == FighterSpecialFrame.IDLE) {
            if (++_autoDirectFrame > 5) {
                _fighter.getCtrler().setDirectToTarget();
                _autoDirectFrame = 0;
            }
        }
    }

    /** @private */
    private function get _fighter():FighterMain {
        return _rt.fighter;
    }

    /** @private */
    private function get _mc():FighterMC {
        return _rt.mc;
    }

    /** @private */
    private function get _action():FighterAction {
        return _rt.action;
    }

    /** @private */
    private function get _actionLogic():FighterActionLogic {
        return _rt.actionLogic;
    }

    /** @private */
    private function get _actionCtrler():IFighterActionCtrl {
        return _rt.actionCtrler;
    }

    /** @private */
    private function get _isTouchFloor():Boolean {
        return _rt.isTouchFloor;
    }

    /** @private */
    private function set _isTouchFloor(v:Boolean):void {
        _rt.isTouchFloor = v;
    }

    /** @private */
    private function get _isFalling():Boolean {
        return _rt.isFalling;
    }

    /** @private */
    private function set _isFalling(v:Boolean):void {
        _rt.isFalling = v;
    }

    /** @private */
    private function get _doingAction():String {
        return _rt.doingAction;
    }

    /** @private */
    private function set _doingAction(v:String):void {
        _rt.doingAction = v;
    }

    /** @private */
    private function get _doingAirAction():String {
        return _rt.doingAirAction;
    }

    /** @private */
    private function set _doingAirAction(v:String):void {
        _rt.doingAirAction = v;
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
            touchFloor();
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
            doJump(_action.jump);
        }
        if (_actionLogic.jumpDown()) {
            doJumpDown(_action.jumpDown);
        }

        if (_action.isMoving) {
            renderMoving();
        }
        if (_action.isDefensing) {
            _hurt.renderDefense();
        }

        if (_actionLogic.ghostStep()) {
            doGhostStep();
        }
        if (_actionLogic.ghostJump()) {
            doGhostJump();
        }

        //仅限连招使用
        if (FighterActionState.isAttacking(_fighter.actionState)) {
            if (_actionLogic.attackAIR()) {
                doAirAttack(_action.attackAIR);
            }
            if (_actionLogic.skillAIR()) {
                doAirSkill(_action.skillAIR);
            }
            if (_actionLogic.bishaAIR()) {
                doAirBisha(_action.bishaAIR, _action.bishaAIRQi);
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
            if (_doActionFrame < 2) {
                doWaiKaiAction(attackingAct, inputText);
                return true;
            }
        }

        return false;
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
        }

        if (_actionLogic.dash()) {
            doDashAir(_action.dash);
        }

        if (_actionLogic.airMove()) {
            doAirMove();
        }
        if (_actionLogic.ghostJump()) {
            doGhostJump();
        }
        if (_actionLogic.ghostJumpDown()) {
            doGhostJumpDown();
        }
    }

    /**
     * 跟随位移目标。
     */
    public function renderMoveTarget():void {
//			var target:IGameSprite = _fighter.getCurrentTarget();
        var target:IGameSprite = _moveTargetParam.target;
        if (!target) {
            return;
        }
//			var targetDisplay:DisplayObject = target.getDisplay();
//			if(!targetDisplay) return;

//			var selfDisplay:DisplayObject = _fighter.getDisplay();
//			if(!selfDisplay) return;

        var aimX:Number;
        var aimY:Number;

        if (_moveTargetParam.followMcName) {
            var mc:DisplayObject = _mc.getChildByName(_moveTargetParam.followMcName);
            if (!mc) {
                return;
            }

            aimX = _fighter.x + mc.x * _fighter.direct;
            aimY = _fighter.y + mc.y;

        }
        else {

            if (!isNaN(_moveTargetParam.x)) {
                aimX = _moveTargetParam.x;
            }
            if (!isNaN(_moveTargetParam.y)) {
                aimY = _moveTargetParam.y;
            }

        }

        if (_moveTargetParam.speed) {
            if (_moveTargetParam.speed.x > 0 && !isNaN(aimX)) {
                if (target.x > aimX + _moveTargetParam.speed.x) {
                    target.x -= _moveTargetParam.speed.x;
                }
                if (target.x < aimX - _moveTargetParam.speed.x) {
                    target.x += _moveTargetParam.speed.x;
                }
                if (target.y > aimY + _moveTargetParam.speed.y) {
                    if (target is BaseGameSprite) {
//							(target as BaseGameSprite).isApplyG = false;
                        (
                                target as BaseGameSprite
                        ).setVecY(-_moveTargetParam.speed.y);
                        (
                                target as BaseGameSprite
                        ).setDampingY(1);
                    }
                    else {
                        target.y -= _moveTargetParam.speed.y;
                    }
                }
                if (target.y < aimY - _moveTargetParam.speed.y) {
                    if (target is BaseGameSprite) {
                        (
                                target as BaseGameSprite
                        ).setVecY(_moveTargetParam.speed.y);
                        (
                                target as BaseGameSprite
                        ).setDampingY(1);
                    }
                    else {
                        target.y += _moveTargetParam.speed.y;
                    }
                }
            }
        }
        else {
            if (!isNaN(aimX)) {
                target.x = aimX;
            }
            if (!isNaN(aimY)) {
                target.y = aimY;
            }
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
    private function renderMoving():void {
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
    private function doMove(action:String, direct:int = 1):void {
        if (_action.isMoving) {
            return;
        }
//			_mc.goFrame(action,false);
        _mc.goFrame(action, true);
        _fighter.actionState = FighterActionState.NORMAL;
        setMoveAction();
    }

    /**
     * 执行空中移动
     */
    private function doAirMove():void {
        if (_actionCtrler.moveLEFT()) {
            _fighter.move(-_fighter.speed);
        }
        if (_actionCtrler.moveRIGHT()) {
            _fighter.move(_fighter.speed);
        }
    }

    /**
     * 执行冲刺
     */
    private function doDash(action:String):void {

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
    private function doJump(action:String):void {
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
    private function doJumpDown(acion:String):void {
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
    private function doAirJump(action:String):void {
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
     * 执行攻击
     */
    private function doAttack(action:String):void {
        _owner.doAction(action, false, null, FighterInputCmd.ATTACK);
        _fighter.actionState = FighterActionState.ATTACK_ING;
    }

    /**
     * 执行技能
     * @param inputText 练习模式输入历史指令（如 WJ / SJ）
     */
    private function doSkill(action:String, inputText:String):void {
        _owner.doAction(action, false, null, inputText);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * 执行摔技
     * @param btnLetter 按键字母 J 或 U，左右由当前方向键决定
     */
    private function doCatch(action:String, btnLetter:String):void {
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
    private function getCatchInputSideLetter():String {
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
    private function doBisha(action:String, qi:int, isSuper:Boolean = false, inputText:String = null):void {
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
    private function doWaiKaiAction(action:String, inputText:String):void {
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

    /**
     * 执行空中必杀
     */
    private function doAirAttack(action:String):void {
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
    private function doAirSkill(action:String):void {
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
    private function doAirBisha(action:String, qi:int):void {
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

    /**
     * 命中指定目标后跳转。
     */
    public function renderCheckTargetHit():void {
        var checkerName:String = _action.hitTargetChecker;
        if (!checkerName) {
            return;
        }

        var rect:Rectangle = _fighter.getCtrler().getHitCheckRect(checkerName);
        if (!rect) {
            return;
        }

        var targets:Vector.<IGameSprite> = _fighter.getTargets();
        if (!targets) {
            return;
        }

        for (var i:int; i < targets.length; i++) {
            if (targets[i] is FighterMain) {
                var body:Rectangle = targets[i].getBodyArea();
                if (body && rect.intersects(body)) {
                    _owner.doAction(_action.hitTarget);
                }
            }
        }

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

    private function doGhostStep():void {
        if (startGhostStep()) {
            _owner.move(8, 0);
            _mc.goFrame(FighterSpecialFrame.MOVE, true);
            _ghostType = 0;
            _owner.dispatchTrainingInput(FighterInputCmd.GHOST_DASH_S);
        }
    }

    private function doGhostJump():void {
        if (startGhostStep()) {
            _owner.move(0, -12);
            _owner.damping(0, 0.1);
            _mc.goFrame(FighterSpecialFrame.JUMP, false);
            _action.jumpTimes--;
            _ghostType = 1;
            _owner.dispatchTrainingInput(FighterInputCmd.GHOST_DASH_W);
        }
    }

    private function doGhostJumpDown():void {
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
