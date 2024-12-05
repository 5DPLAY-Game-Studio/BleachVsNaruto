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

package net.play5d.game.bvn.fighter.ctrler {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrl.EffectCtrl;
import net.play5d.game.bvn.ctrl.GameLogic;
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.HitType;
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.data.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.fighter.vos.MoveTargetParamVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterMcCtrler {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterMcCtrler(fighter:FighterMain) {
//			_mc = mc;
        _fighter     = fighter;
        _actionLogic = new FighterActionLogic(fighter);
    }
    public var effectCtrler:FighterEffectCtrl;
    private var _actionCtrler:IFighterActionCtrl; //角色操作控制
    private var _mc:FighterMC; //角色SWF中的MC元件控制
    private var _fighter:FighterMain; //角色SWF主类
    private var _action:FighterAction = new FighterAction(); //动作定义
    private var _doingAction:String; //当前动作
    private var _doingAirAction:String; //当前空中动作
    private var _isFalling:Boolean; //是否正在落下
    private var _jumpDelayFrame:int = 0; //跳跃延时（帧）
    private var _hurtHoldFrame:int    = 0; //被打延时
    private var _defenseHoldFrame:int = 0; //防御延时
    private var _beHitGap:int; //受攻击间隔(帧)
    private var _doActionFrame:int; //执行动作的帧数
    private var _isTouchFloor:Boolean = true;//是否已经在地上
    private var _isDefense:Boolean; //是否正在防御
    private var _defenseFrameDelay:int = 0;
    private var _moveTargetParam:MoveTargetParamVO; //是否正在防御
    private var _hurtDownFrame:int;
    private var _ghostStepIng:Boolean;
    private var _ghostStepFrame:int;
    private var _autoDirectFrame:int;
    private var _justDefenseFrame:int;
    private var _ghostType:int = 0;
    private var _justHurtResume:Boolean;
    private var _actionLogic:FighterActionLogic;

    public function destory():void {
        if (_actionCtrler) {
            _actionCtrler.destory();
            _actionCtrler = null;
        }
        if (_mc) {
            _mc.destory();
            _mc = null;
        }
        _fighter         = null;
        _action          = null;
        _moveTargetParam = null;
        effectCtrler     = null;
    }

    public function getAction():FighterAction {
        return _action;
    }

    public function getFighterMc():FighterMC {
        return _mc;
    }

    public function getCurAction():String {
        if (_doingAirAction != null) {
            return _doingAirAction;
        }
        return _doingAction;
    }

    public function getActionCtrler():IFighterActionCtrl {
        return _actionCtrler;
    }

    /**
     * 操作控制
     */
    public function setActionCtrler(v:IFighterActionCtrl):void {
        _actionCtrler = v;
    }

    /**
     * 设定MC元件
     */
    public function setMc(mc:FighterMC):void {
        _mc = mc;
        idle();
    }

    /**
     * 设定MC元件
     */
    public function initMc(source:MovieClip):FighterMC {
        _mc = new FighterMC();
        _mc.initlize(source, _fighter, this);
        idle();
        return _mc;
    }

    /**
     * 设置钢身状态
     * @param v
     * parent.$mc_ctrler.setSteelBody(true);
     * parent.$mc_ctrler.setSteelBody(true, true);
     */
    public function setSteelBody(v:Boolean, isSuper:Boolean = false):void {
        _fighter.isSteelBody      = v;
        _fighter.isSuperSteelBody = v && isSuper;
        if (v) {
            effectCtrler.startGlow(isSuper ? 0xffff00 : 0xffffff);
        }
        else {
            effectCtrler.endGlow();
        }
    }


    //----------------------------------------------------------------------------------------------
    //    帧上调用方法     =============================================================================
    //----------------------------------------------------------------------------------------------

    //增加气力
    public function addQi(qi:Number):void {
        _fighter.addQi(qi);
    }

    //恢复状态
    public function idle(frame:String = FighterSpecialFrame.IDLE):void {

        if (!_fighter.isAlive) {
            trace('not alive!!!');
            return;
        }

        if (FighterActionState.isHurting(_fighter.actionState)) {
            _justHurtResume = true;
        }

        endAct();
        _doingAction    = null;
        _doingAirAction = null;

        setSteelBody(false);

        _justDefenseFrame = 0.1 * GameConfig.FPS_GAME;

        effectCtrler.endShadow();
        effectCtrler.endShake();

        _action.clearAction();
        _action.clearState();

        _fighter.actionState  = FighterActionState.NORMAL;
        _fighter.isAllowBeHit = !_justHurtResume;
        _fighter.isApplyG     = true;
        _fighter.isCross      = false;
        _fighter.hurtHit      = null;
        _fighter.defenseHit   = null;
        _fighter.clearHurtHits();
        _fighter.getDisplay().visible = true;

        _isDefense = false;

        _autoDirectFrame = 0;

//			if(_doingAirAction){
//			if(_fighter.isInAir){
        if (!_isTouchFloor) {
            fall();
//				trace('!_isTouchFloor.fall');
        }
        else {
            var isPlay:Boolean = true;
            _fighter.setVelocity(0, 0);
            if (frame == FighterSpecialFrame.IDLE) {
                isPlay              = false;
                _action.jumpTimes   = _fighter.jumpTimes;
                _action.airHitTimes = _fighter.airHitTimes;
                setAllAct();
            }
            _mc.goFrame(frame, isPlay);
        }

        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.IDLE);
    }

    //循环播放  parent.$mc_ctrler.loop("走");
    public function loop(frame:String):void {
        _mc.goFrame(frame);
    }

    //停止播放   parent.$mc_ctrler.stop();
    public function stop():void {
        _mc.stopRenderMainAnimate();
    }

    //执行冲刺
    public function dash(speedPlus:Number = 3):void {
        _action.isDashing = true;
        _fighter.setVelocity(_fighter.speed * speedPlus * _fighter.direct, 0);
        _fighter.setDamping(0, 0);
        _fighter.isCross      = true;
        _fighter.isAllowBeHit = false;
    }

    //执行冲刺结束
    public function dashStop(loseSpdPercent:Number = 0.5):void {
        var vecx:Number    = _fighter.getVecX();
        var damping:Number = Math.abs(vecx) * loseSpdPercent;
        _fighter.setDamping(damping);
        _fighter.isAllowBeHit = true;
        _fighter.actionState  = FighterActionState.NORMAL;
        _action.clearAction();
        _action.isDashing = false;
        _fighter.isCross  = false;
    }

    //设定所有的动作
    public function setAllAct():void {
        setMove();
        setDefense();
        setJump();
        setJumpDown();
        setDash();

        setAttack();

        setSkill1();
        setSkill2();

        setZhao1();
        setZhao2();
        setZhao3();

        setCatch1();
        setCatch2();

        setBisha();
        setBishaUP();
        setBishaSUPER();

        setWankai();

    }

    //设定所有空中的动作
    public function setAirAllAct():void {
        setDash();
        setAttackAIR();
        setSkillAIR();
        setBishaAIR();
        setAirMove(true);
    }

    public function setAirMove(v:Boolean):void {
        _action.airMove = v;
    }

    //设定行走
    public function setMove():void {
        setMoveLeft();
        setMoveRight();
    }

    public function setMoveLeft():void {
        _action.moveLeft = FighterSpecialFrame.MOVE;
    }

    public function setMoveRight():void {
        _action.moveRight = FighterSpecialFrame.MOVE;
    }

    //设定防御
    public function setDefense():void {
        _action.defense = FighterSpecialFrame.DEFENSE;
    }

    //设定跳
    public function setJump(action:String = FighterSpecialFrame.JUMP):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jump = action;
    }

    //设定跳2
    public function setJumpQuick(action:String = FighterSpecialFrame.JUMP):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jumpQuick = action;
    }

    //设定从空中的板中跳下
    public function setJumpDown(action:String = FighterSpecialFrame.JUMP_DOWN):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jumpDown = action;
    }

    //设定冲刺
    public function setDash(action:String = FighterSpecialFrame.DASH):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.dash = action;
    }

    //设定普通攻击J  parent.$mc_ctrler.setAttack("砍1");
    public function setAttack(action:String = FighterSpecialFrame.ATTACK):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.attack = action;
    }

    //设定技能攻击S+J
    public function setSkill1(action:String = FighterSpecialFrame.SKILL_1):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skill1 = action;
    }

    //设定技能攻击W+J
    public function setSkill2(action:String = FighterSpecialFrame.SKILL_2):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skill2 = action;
    }

    //设定技能攻击U  parent.$mc_ctrler.setZhao1();
    public function setZhao1(action:String = FighterSpecialFrame.ZHAO_1):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao1 = action;
    }

    //设定技能攻击S+U  parent.$mc_ctrler.setZhao2();
    public function setZhao2(action:String = FighterSpecialFrame.ZHAO_2):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao2 = action;
    }

    //设定技能攻击W+U  parent.$mc_ctrler.setZhao3();
    public function setZhao3(action:String = FighterSpecialFrame.ZHAO_3):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao3 = action;
    }

    public function setCatch1(action:String = FighterSpecialFrame.CATCH_1):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.catch1 = action;
    }

    public function setCatch2(action:String = FighterSpecialFrame.CATCH_2):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.catch2 = action;
    }

    //设定必杀I  parent.$mc_ctrler.setBisha();
    public function setBisha(action:String = FighterSpecialFrame.BISHA, qi:int = 100):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bisha   = action;
        _action.bishaQi = qi;
    }

    //设定必杀W+I
    public function setBishaUP(action:String = FighterSpecialFrame.BISHA_UP, qi:int = 100):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaUP   = action;
        _action.bishaUPQi = qi;
    }

    //设定必杀S+I
    public function setBishaSUPER(action:String = FighterSpecialFrame.BISHA_SUPER, qi:int = 300):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaSUPER   = action;
        _action.bishaSUPERQi = qi;
    }

    //设定空中普通攻击J
    public function setAttackAIR(action:String = FighterSpecialFrame.ATTACK_AIR):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.attackAIR = action;
    }

    //设定空中技能U
    public function setSkillAIR(action:String = FighterSpecialFrame.SKILL_AIR):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skillAIR = action;
    }

    //设定空中必杀I
    public function setBishaAIR(action:String = FighterSpecialFrame.BISHA_AIR, qi:int = 100):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaAIR   = action;
        _action.bishaAIRQi = qi;
    }

    //设定落地的动作,breakAct:接触到地面时是否中断当前动作
    public function setTouchFloor(action:String = FighterSpecialFrame.JUMP_TOUCH_FLOOR, breakAct:Boolean = true):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.touchFloor         = action;
        _action.touchFloorBreakAct = breakAct;
//			trace('setTouchFloor' ,action , breakAct);
    }

    //设定万解
    public function setWankai():void {
        if (_mc.checkFrame(FighterSpecialFrame.BANKAI)) {
            _action.waiKai = FighterSpecialFrame.BANKAI;
        }
        if (_mc.checkFrame(FighterSpecialFrame.BANKAI_W)) {
            _action.waiKaiW = FighterSpecialFrame.BANKAI_W;
        }
        if (_mc.checkFrame(FighterSpecialFrame.BANKAI_S)) {
            _action.waiKaiS = FighterSpecialFrame.BANKAI_S;
        }
    }

    //设定检测碰撞后攻击,checker:检测对象名称，action碰撞后执行的动作
    public function setHitTarget(checker:String, action:String):void {
        _action.hitTarget        = action;
        _action.hitTargetChecker = checker;
    }

    public function setHurtAction(action:String):void {
        _action.hurtAction   = action;
        _fighter.actionState = FighterActionState.HURT_ACT_ING;
    }

    //移动  MC调用SAMPLE parent.$mc_ctrler.move(1,0);
    public function move(x:Number = 0, y:Number = 0):void {
        if (x == 0 && y == 0) {
            stopMove();
            return;
        }
        if (_fighter.isInAir && x != 0) {
            _action.airMove = false;
        }
        x *= _fighter.direct;
        _fighter.setVelocity(x, y);
    }

    //按角色速度百分比移动 MC调用SAMPLE parent.$mc_ctrler.movePercent(1,0);
    public function movePercent(x:Number = 0, y:Number = 0):void {
        move(_fighter.speed * x, _fighter.speed * y);
    }

    //停止移动 MC调用SAMPLE parent.$mc_ctrler.stopMove();
    public function stopMove():void {
        _fighter.setVelocity(0, 0);
    }

    //设置阻尼
    public function damping(x:Number = 0, y:Number = 0):void {
        _fighter.setDamping(x, y);
    }

    //按角色速度的百分比设置阻尼 MC调用SAMPLE：parent.$mc_ctrler.dampingPercent(0.5,0);
    public function dampingPercent(x:Number = 0, y:Number = 0):void {
        _fighter.setDamping(_fighter.speed * x, _fighter.speed * y);
    }

    //结束动作  parent.$mc_ctrler.endAct();
    public function endAct():void {
        _action.clearAction();
//			isApplyG(true);
        //			_doingAction = null;
        _fighter.actionState = FighterActionState.FREEZE;
//			_fighter.isAllowBeHit = true;
//			_fighter.isCross = false;
        _moveTargetParam = null;
        setSteelBody(false);
    }

    //放波，子弹
    public function fire(mcName:String, params:Object = null):void {

        var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
        if (mc) {
            params ||= {};
            params.mc    = mc;
            params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);

            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.FIRE_BULLET, params);
        }
        else {
            _fighter.setAnimateFrameOut(function ():void {
                fire(mcName, params);
            }, 1);
        }

    }

    public function addAttacker(mcName:String, params:Object = null):void {
        var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
        if (mc) {
            params ||= {};
            params.mc    = mc;
            params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);

            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.ADD_ATTACKER, params);
        }
        else {
            _fighter.setAnimateFrameOut(function ():void {
                addAttacker(mcName, params);
            }, 1);
        }
    }

    /**
     * 是否接受重力
     */
    public function isApplyG(v:Boolean):void {
        _fighter.isApplyG = v;
    }

    public function gotoAndPlay(frame:String):void {
        _mc.goFrame(frame, true);
    }

    public function gotoAndStop(frame:String):void {
        _mc.goFrame(frame, false);
    }

    public function hurtFly(x:Number, y:Number):void {
        _mc.playHurtFly(x * _fighter.direct, y, false);
        _action.isHurtFlying = true;
        _fighter.actionState = FighterActionState.HURT_FLYING;
        _hurtDownFrame       = 0;
        _isFalling           = false;
    }

    public function moveMC(mmc:DisplayObject, x:Object = null, y:Object = null):void {
        var target:IGameSprite = _fighter.getCurrentTarget();
//			var targetDisplay:DisplayObject = target ? target.getDisplay() : null;

        if (x) {
            if (x is Number) {
                mmc.x = _fighter.x + x;
            }
            else {
                if (x.target != undefined && target) {
                    mmc.x = target.x - _fighter.x;
                    if (isNaN(Number(x.target))) {
                        mmc.x += Number(x.target);
                    }
                }
            }
        }

        if (y) {
            if (y is Number) {
                mmc.y = _fighter.y + y;
            }
            else {
                if (y.target != undefined && target) {
                    mmc.y = target.y - _fighter.y + Number(y);
                    if (isNaN(Number(y.target))) {
                        mmc.y += Number(y.target);
                    }
                }
            }
        }

    }

    /**
     * 刚刚打击到指定的攻击，跳转到相应的frame label
     * @param hitid 攻击ID，不带atm
     * @param frame 成功后跳转到相应的帧标签
     * @param noIdle 如果没打中，是否跳转到IDLE
     * @param inCludeDefense 对方防御时是否继续攻击
     */
    public function justHitToPlay(hitid:String, frame:String, noIdle:Boolean = false,
                                  inCludeDefense:Boolean                     = false
    ):void {
        if (_fighter.getCtrler().justHit(hitid, inCludeDefense)) {
            _mc.goFrame(frame);
        }
        else {
            if (noIdle) {
                idle();
            }
        }
    }

    public function getAttacker(name:String):FighterAttackerCtrler {
        var attacker:FighterAttacker = GameCtrl.I.getAttacker(name, _fighter.team.id);
        if (attacker) {
            return attacker.getCtrler();
        }
        return null;
    }

    /**
     * 设置攻击对向的位置 ，当params为NULL时，结束移动
     * params:{
     * 		x:Number X位置
     * 		y:Number Y位置
     * 		followmc:String 按MC的位置移动目标，MC名称
     * 		speed:Number|{x:Number,y:Number} 移动速度，0或不设置时，直接移动到相应位置
     * }
     */
    public function moveTarget(params:Object = null):void {
        if (!params) {
            _moveTargetParam.clear();
            _moveTargetParam = null;
            return;
        }
        _moveTargetParam = new MoveTargetParamVO(params);
        _moveTargetParam.setTarget(_fighter.getCurrentTarget());
    }

    //-----------------------------------------------------------------------------------------------
    //   帧调用方法结束  ===============================================================================
    //-----------------------------------------------------------------------------------------------

    public function render():void {

        if (_ghostStepIng) {
            return;
        }

        if (_justDefenseFrame > 0) {
            _justDefenseFrame--;
        }

        _action.render();

        if (_moveTargetParam) {
            renderMoveTarget();
        }

        if (_actionCtrler) {
            _actionCtrler.render();
        }

//			renderAssist();

        if (_action.isHurtFlying) {
            renderHurtFlying();
            return;
        }

        if (_action.isHurting) {
            renderHurt();
            return;
        }

        if (_action.isDefenseHiting) {
            renderDefense(false, true);
            return;
        }

        if (_action.hitTarget) {
            renderCheckTargetHit();
        }
        if (renderWanKaiCtrl()) {
            return;
        }

        if ((
                    _fighter && _fighter.isInAir
            ) || (
                    _doingAirAction && !_action.touchFloorBreakAct
            )) {
            renderAirAction();
        }
        else {
            renderFloorAction();
        }


    }

    public function renderAnimate():void {

        if (_justHurtResume) {
            _fighter.isAllowBeHit = true;
            _justHurtResume       = false;
        }

        renderBeHitGap();

        if (_mc) {
            _mc.renderAnimate();
        }

        if (_actionCtrler) {
            _actionCtrler.renderAnimate();
        }

        if (_ghostStepIng) {
            renderGhostStep();
            return;
        }

        if (_action) {
            if (_action.isHurting) {
                renderHurtAnimate();
            }
            if (_action.isDefenseHiting) {
                renderDefensHiting();
            }

            if (_action.isJumping) {
                renderJumpAnimate();
            }

            if (_doingAction) {
                _doActionFrame++;
            }
            if (_action.isDefensing) {
                renderDefenseAnimate();
            }
        }

        if (_mc && _mc.currentFrameName == FighterSpecialFrame.IDLE) {
            if (++_autoDirectFrame > 5) {
                _fighter.getCtrler().setDirectToTarget();
                _autoDirectFrame = 0;
            }
        }
    }

    /**
     * 落地
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

        var delayParam:Object = act == FighterSpecialFrame.JUMP_TOUCH_FLOOR ? {call: setAttack, delay: 1} : null;
        doAction(act, false, delayParam);
        effectCtrler.touchFloor();

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
                setAirAllAct();
                if (_fighter.isInAir) {
                    effectCtrler.jumpAir();
                }
                else {
                    effectCtrler.jump();
                }
//					setJumpQuick();
            }
            return;
        }

        if (_mc.getCurrentFrameCount() == 2) {
            setJumpQuick();
        }

        var vecy:Number = _fighter.getVecY();
        if (_mc.currentFrameName != FighterSpecialFrame.JUMP_ING && vecy > -_fighter.jumpPower * 0.35) {
            _mc.goFrame(FighterSpecialFrame.JUMP_ING, false);
//				setJump();
            _fighter.setAnimateFrameOut(setJump, 5);
        }

        if (vecy >= 0) {
            _action.isJumping = false;
            _isFalling        = true;
        }
    }

    public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {

        if (_action.hurtAction) {
            doAction(_action.hurtAction);
            return;
        }

        if (_fighter.getIsTouchSide()) {
            if (hitvo.owner && hitvo.owner is BaseGameSprite) {
                var ownersp:BaseGameSprite = hitvo.owner as BaseGameSprite;
                if (Math.abs(_fighter.x - hitvo.owner.x) < 100) {
//						var dampingX:Number = _isDefense ?
//							GameConfig.DEFENSE_DAMPING_X :
//							(hitvo.hurtType == 1 ? 0.2 : GameConfig.HURT_DAMPING_X);
                    var dampingX:Number = 0.3;
                    var vecx:Number     = -hitvo.hitx * ownersp.direct * 1.4;
                    if (vecx > 20) {
                        vecx = 20;
                    }
                    if (vecx < -20) {
                        vecx = -20;
                    }
                    ownersp.setVec2(vecx, 0, dampingX, 0);
                }
            }
        }

        if (_isDefense) {

//				if(hitvo.isBreakDef && hitvo.hitType == HitType.CATCH){
            if (hitvo.isBreakDef && hitvo.hitType == HitType.CATCH) {
                doHurt(hitvo, hitRect);
                return;
            }

            if (hitvo.checkDirect && hitvo.owner) {
                if (checkDefDirect(hitvo.owner)) {
                    doHurt(hitvo, hitRect);
                    return;
                }
            }

            doDefenseHit(hitvo, hitRect);
        }
        else {
            if (_fighter.isSteelBody && _fighter.isAlive) {
                doSteelHurt(hitvo, hitRect);
            }
            else {
                doHurt(hitvo, hitRect);
            }
        }

    }

    /**
     * 开场
     */
    public function sayIntro():void {
        _fighter.actionState = FighterActionState.KAI_CHANG;
        _mc.goFrame("开场");
    }

    /**
     * 胜利
     */
    public function doWin():void {
        _fighter.actionState = FighterActionState.WIN;
        _mc.goFrame("胜利");
    }

    /**
     * 失败
     */
    public function doLose():void {
        _fighter.actionState = FighterActionState.LOSE;
        _mc.goFrame("失败");
    }

    //正在被击飞
    private function renderHurtFlying():void {
        if (!_fighter.isInAir) {
            _isTouchFloor = true;
        }

        if (!_fighter.isAlive) {
            return;
        }

        if (_fighter.actionState == FighterActionState.HURT_DOWN_TAN) {
            _hurtDownFrame = 1;
        }

        if (_hurtDownFrame > 0) {
            if (!_actionLogic || !_actionLogic.enabled()) {
                return;
            }
            if (++_hurtDownFrame < GameConfig.HURT_DOWN_JUMP_FRAME) {
                if (_actionLogic.hurtFlyResume()) {
                    doHurtDownJump();
                    _hurtDownFrame = 0;
                }
            }
        }

    }

    //招唤
    private function renderSpecial():void {
//			if(_fighter.actionState != FighterActionState.NORNAL && _fighter.actionState !=
// FighterActionState.DEFENCE_ING) return;

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

    private function renderFloorAction():void {
        if (!_fighter.isAlive) {
            return;
        }

        if (!_isTouchFloor) {
            touchFloor();
        }

        if (_actionLogic == null || !_actionLogic.enabled()) {
            if (_mc.currentFrameName == FighterSpecialFrame.MOVE || _mc.currentFrameName == FighterSpecialFrame.DEFENSE) {
                idle();
            }
            return;
        }

        renderSpecial();

        if (_actionLogic.catch1()) {
            doCatch(_action.catch1);
        }
        if (_actionLogic.catch2()) {
            doCatch(_action.catch2);
        }

        if (_actionLogic.bishaSUPER()) {
            doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true);
        }
        if (_actionLogic.bishaUP()) {
            doBisha(_action.bishaUP, _action.bishaUPQi);
        }
        if (_actionLogic.bisha()) {
            doBisha(_action.bisha, _action.bishaQi);
        }

        if (_actionLogic.skill2()) {
            doSkill(_action.skill2);
        }
        if (_actionLogic.skill1()) {
            doSkill(_action.skill1);
        }

        if (_actionLogic.zhao3()) {
            doSkill(_action.zhao3);
        }
        if (_actionLogic.zhao2()) {
            doSkill(_action.zhao2);
        }

        if (_actionLogic.attack()) {
            doAttack(_action.attack);
        }

        if (_actionLogic.zhao1()) {
            doSkill(_action.zhao1);
        }

        if (_actionLogic.defense()) {
            doDefense();
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
            renderDefense();
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

    private function renderWanKaiCtrl():Boolean {
        if (!_actionLogic || !_actionLogic.enabled()) {
            return false;
        }

        if (_actionLogic.waiKai()) {
            return checkDoWankai(_action.waiKai, FighterSpecialFrame.BANKAI);
        }
        if (_actionLogic.waiKaiW()) {
            return checkDoWankai(_action.waiKaiW, FighterSpecialFrame.BANKAI_W);
        }
        if (_actionLogic.waiKaiS()) {
            return checkDoWankai(_action.waiKaiS, FighterSpecialFrame.BANKAI_S);
        }

        return false;
    }

    private function checkDoWankai(action:String, attackingAct:String):Boolean {
        if (action) {
            doWaiKaiAction(action);
            return true;
        }

        if (_doingAction == FighterSpecialFrame.ATTACK) {
            if (_doActionFrame < 2) {
                doWaiKaiAction(attackingAct);
                return true;
            }
        }

        return false;
    }

    private function renderAirAction():void {

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
                doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true);
            }
            if (_actionLogic.bishaUP()) {
                doBisha(_action.bishaUP, _action.bishaUPQi);
            }
            if (_actionLogic.bisha()) {
                doBisha(_action.bisha, _action.bishaQi);
            }

            if (_actionLogic.skill2()) {
                doSkill(_action.skill2);
            }
            if (_actionLogic.skill1()) {
                doSkill(_action.skill1);
            }

            if (_actionLogic.zhao3()) {
                doSkill(_action.zhao3);
            }
            if (_actionLogic.zhao2()) {
                doSkill(_action.zhao2);
            }

            if (_actionLogic.attack()) {
                doAttack(_action.attack);
            }

            if (_actionLogic.zhao1()) {
                doSkill(_action.zhao1);
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

    private function renderMoveTarget():void {
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
    private function fall():void {
        if (_isFalling) {
            return;
        }
        if (_doingAction) {
            return;
        }

        _action.clearState();
        _action.clearAction();

        setAirAllAct();
        setJump();

        _isFalling      = true;
        _doingAirAction = null;
        _isTouchFloor   = false;
        _isDefense      = false;

        _fighter.setVecX(0);

        setTouchFloor(FighterSpecialFrame.JUMP_TOUCH_FLOOR, true);

        _mc.goFrame(FighterSpecialFrame.JUMP_DOWN, false);
    }

    /**
     * 执行动作
     */
    private function doAction(action:String, airAct:Boolean = false, delayParam:Object = null):void {

        if (action == null) {
            return;
        }

        effectCtrler.endShadow();
        effectCtrler.endShake();

        _fighter.setVelocity(0, 0);

        _action.isMoving    = false;
        _action.isDefensing = false;
        _action.isDashing   = false;

        _doingAction    = action;
        _doingAirAction = airAct ? action : null;

        _action.clearAction();
        _isFalling = false;

        _isDefense = false;

        _fighter.isAllowBeHit = true;
        _fighter.isCross      = false;
        _fighter.isApplyG     = true;

        _doActionFrame = 0;
        _mc.goFrame(action, true, 0, delayParam);

        _fighter.dispatchEvent(new FighterEvent(FighterEvent.DO_ACTION));
    }

    /**
     * 设定可移动
     */
    private function setMoveAction():void {
        _action.clearAction();

        _action.isMoving = true;

        setMove();
        setAttack();

        setZhao1();
//			setZhao2();
        setZhao3();

//			setSkill1();
        setSkill2();

        setJump();
        setDash();
        setBisha();
        setBishaUP();
//			setBishaSUPER();

        setDefense();

        setCatch1();
        setCatch2();

    }

    /**
     * 正在移动
     */
    private function renderMoving():void {
        if (_actionCtrler.moveLEFT()) {
            _fighter.direct = -1;
            move(_fighter.speed);
        }
        else if (_actionCtrler.moveRIGHT()) {
            _fighter.direct = 1;
            move(_fighter.speed);
        }
        else {
            idle();
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
     * 正在防御（动画控制）
     */
    private function renderDefense(setActions:Boolean = true, isJustDefense:Boolean = false):void {

//			renderBeHitGap();

        if (_actionCtrler.moveLEFT()) {
            if (_fighter.direct != -1) {
                _fighter.direct = -1;
                setDefenseAction(setActions, isJustDefense);
            }
        }

        if (_actionCtrler.moveRIGHT()) {
            if (_fighter.direct != 1) {
                _fighter.direct = 1;
                setDefenseAction(setActions, isJustDefense);
            }
        }

    }

    private function renderDefenseAnimate():void {
        if (_action.isDefenseHiting) {
            return;
        }
        if (_defenseFrameDelay-- > 0) {
            return;
        }

        if (_actionCtrler.enabled() && _actionCtrler.defense()) {
            if (!_isDefense) {
                _isDefense = true;
            }
        }
        else {
            if (_defenseFrameDelay > -5) {
                return;
            }
            _action.isDefensing = false;
            _mc.goFrame(FighterSpecialFrame.DEFENSE_RESUME, false, 0, {call: idle, delay: 1});
        }
    }

    /**
     * 设定防御动作
     */
    private function setDefenseAction(setActions:Boolean = true, isJustDefense:Boolean = false):void {
//			trace('setDefenseAction');

        if (setActions) {
            _action.clearAction();
            _action.clearState();

            _action.isDefensing = true;
            setSkill1();
            setZhao2();
            setBishaSUPER();
            setJumpDown();
        }

        if (isJustDefense) {
            _isDefense = true;
        }
        else {
            _isDefense = _justDefenseFrame > 0 ? true : false;
        }

        _defenseFrameDelay = 1;

        _mc.goFrame(FighterSpecialFrame.DEFENSE, true, 3);

        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DEFENSE);
    }

    /**
     * 执行防御
     */
    private function doDefense():void {
        if (_action.isDefensing) {
            return;
        }

        _fighter.actionState = FighterActionState.DEFENCE_ING;
        dampingPercent(1, 1);
        setDefenseAction();
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
        doAction(action);
        _fighter.actionState  = FighterActionState.DASH_ING;
        _fighter.isAllowBeHit = false;
        isApplyG(false);
    }

    private function doDashAir(action:String):void {
        if (_action.jumpTimes < 1) {
            return;
        }
        if (!_fighter.hasEnergy(30, true)) {
            return;
        }
        _fighter.useEnergy(30);

        doAction(action);
        _fighter.actionState  = FighterActionState.DASH_ING;
        _fighter.isAllowBeHit = false;
        isApplyG(false);
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
        _isDefense = false;
        _mc.goFrame(acion, false);
        setTouchFloor();
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


    }

    /**
     * 执行攻击
     */
    private function doAttack(action:String):void {
        doAction(action);
        _fighter.actionState = FighterActionState.ATTACK_ING;
    }

    /**
     * 执行技能
     */
    private function doSkill(action:String):void {
        doAction(action);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * 执行摔技
     */
    private function doCatch(action:String):void {
        if (!allowCatch()) {
            return;
        }
//			if(!_action.CDOK("catch")) return;
//			_action.setCD("catch" , 5000);

        doAction(action);
        _fighter.actionState = FighterActionState.SKILL_ING;
    }

    /**
     * 执行必杀
     */
    private function doBisha(action:String, qi:int, isSuper:Boolean = false):void {
        if (!_fighter.useQi(qi)) {
            return;
        }

        _fighter.actionState = isSuper ? FighterActionState.BISHA_SUPER_ING : FighterActionState.BISHA_ING;

        doAction(action);
    }

    /**
     * 执行必杀
     */
    private function doWaiKaiAction(action:String):void {
        if (!_mc.checkFrame(action)) {
            return;
        }
        if (!_fighter.useQi(300)) {
            return;
        }
        ;
        _fighter.actionState = FighterActionState.WAN_KAI_ING;
        doAction(action);
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

        doAction(action, true);

        _fighter.actionState = FighterActionState.ATTACK_ING;
    }

    /**
     * 执行空中技能
     */
    private function doAirSkill(action:String):void {
        if (_doingAction == null && _action.airHitTimes <= 0) {
            return;
        }

        if (_action.isJumping) {
            var act:String = null;
            if (_actionCtrler.zhao3()) {
                act = FighterSpecialFrame.SKILL_AIR_W;
            }
            if (_actionCtrler.zhao2()) {
                act = FighterSpecialFrame.SKILL_AIR_S;
            }
            if (act && _mc.checkFrame(act)) {
                action = act;
            }
        }

        //			fighter.setVelocity(0,0);

        _action.airHitTimes = 0;
        _action.jumpTimes   = 0;

        doAction(action, true);
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
        doAction(action, true);
    }

    //判断是否背对着敌人
    private function checkDefDirect(hiter:IGameSprite):Boolean {
        var minx:int = 5;
        if (_fighter.x < hiter.x - minx) {
            return _fighter.direct < 0 && hiter.direct < 0;
        }
        if (_fighter.x > hiter.x + minx) {
            return _fighter.direct > 0 && hiter.direct > 0;
        }
        return false;
    }

    private function doSteelHurt(hitvo:HitVO, hitRect:Rectangle):void {

//			if(_fighter.energyOverLoad){
//				doHurt(hitvo, hitRect);
//				return;
//			}

        if (!_fighter.isSuperSteelBody && (
                _fighter.energyOverLoad || hitvo.isBisha() || hitvo.isCatch()
        )) {
            doHurt(hitvo, hitRect);
            return;
        }

        _fighter.hurtHit = hitvo;
        if (_fighter.isSuperSteelBody) {
            _fighter.loseHp(hitvo.getDamage() * GameConfig.STEEL_SUPER_HURT_HP_PERCENT);
        }
        else {
            _fighter.loseHp(hitvo.getDamage() * GameConfig.STEEL_HURT_HP_PERCENT);
        }

        if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
            _fighter.isAlive = false;
            doHurt(hitvo, hitRect);
            return;
        }

        if (hitvo.hurtType == 1) {
            _beHitGap = GameConfig.STEEL_HURT_DOWN_GAP_FRAME;
        }
        else {
            _beHitGap = GameConfig.STEEL_HURT_GAP_FRAME;
        }

        if (_fighter.isSuperSteelBody) {
            _fighter.useEnergy(hitvo.getDamage() * 0.2);
        }
        else {
            if (hitvo.isBreakDef) {
                _fighter.useEnergy(hitvo.getDamage());
            }
            else {
                _fighter.useEnergy(hitvo.getDamage() * 0.4);
            }
        }

        _fighter.isAllowBeHit = false;

        if (!_fighter.isSuperSteelBody) {
            var hitx:Number = hitvo.hitx;
            var hity:Number = hitvo.hity;
            if (hitvo.owner) {
                hitx *= hitvo.owner.direct;
            }

            var vev2X:Number = hitx;
            var vev2Y:Number = hity;
            if (hitvo.isBreakDef) {
                vev2X *= 2;
                vev2Y *= 2;
            }

            _fighter.setVec2(vev2X, vev2Y, Math.abs(hitx * 0.1), Math.abs(hity * 0.1));
        }

//			if(hitvo && hitRect) EffectCtrl.I.doHitEffect(hitvo , hitRect , _fighter);
        if (hitvo && hitRect) {
            EffectCtrl.I.doSteelHitEffect(hitvo, hitRect, _fighter);
        }
    }

    private function doHurt(hitvo:HitVO, hitRect:Rectangle):void {
        if (hitvo && hitRect) {
            EffectCtrl.I.doHitEffect(hitvo, hitRect, _fighter);
        }

        _fighter.hurtHit = hitvo;
        _fighter.loseHp(hitvo.getDamage());

        _fighter.isAllowBeHit = false;
        _beHitGap             = GameConfig.HURT_GAP_FRAME;

        if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
            _fighter.isAlive = false;
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
        }

        if (!_fighter.isAlive || !hitvo.isWeakHit()) {
            doHurtAnimate(hitvo, hitRect);
        }
    }

    private function doHurtAnimate(hitvo:HitVO, hitRect:Rectangle):void {
        effectCtrler.endShadow();
        effectCtrler.endShake();

        _fighter.isApplyG = true;
        _isDefense        = false;

        var hitx:Number = hitvo.hitx;
        var hity:Number = hitvo.hity;

        // 无双模式 - 小兵特殊处理
        if (_fighter.mosouEnemyData && !_fighter.mosouEnemyData.isBoss) {
            if (!_fighter.isAlive) {
                if (hity > 0) {
                    hity += Math.random() * 3;
                }
                else {
                    hity -= 3 + Math.random() * 3;
                }
                hitx += 2 + Math.random() * 3;
            }
        }
        // ---------------------------------------------------------------------------

        if (hitvo.owner) {
            hitx *= hitvo.owner.direct;
        }

        if (_fighter.isInAir) {
            if (hity <= 0) {
                hity -= GameConfig.HURT_Y_ADD_INAIR;
            }
        }
        else {
            if (hity < 0) {
                hity -= GameConfig.HURT_Y_ADD;
                _isTouchFloor = false;
            }
        }

        _action.clearState();
        _doingAirAction = null;
        _doingAction    = null;
        setSteelBody(false);

        if (hitvo.hurtType == 0) {
            _action.isHurting = true;
            _hurtHoldFrame    = Math.round((
                                                   hitvo.hurtTime / 1000
                                           ) * GameConfig.FPS_ANIMATE) + GameConfig.HURT_FRAME_OFFSET;
            if (_hurtHoldFrame < GameConfig.HURT_GAP_FRAME) {
                _hurtHoldFrame = GameConfig.HURT_GAP_FRAME;
            }

            if (hitvo.hitType == HitType.CATCH) {
                _mc.goFrame(FighterSpecialFrame.HURT, false);
            }
            else {
                _mc.goFrame(FighterSpecialFrame.HURT, true, 7);
            }

            _fighter.actionState = FighterActionState.HURT_ING;

            _fighter.setVelocity(hitx, hity);
            _fighter.setDamping(GameConfig.HURT_DAMPING_X, GameConfig.HURT_DAMPING_Y);

            if (_fighter.isAlive && HitType.isHeavy(hitvo.hitType)) {
                _fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.HURT, 0.5);
            }

        }

        if (hitvo.hurtType == 1) {
            _action.isHurtFlying = true;
            _fighter.actionState = FighterActionState.HURT_FLYING;
            _hurtDownFrame       = 0;

            _mc.playHurtFly(hitx, hity);

            if (_fighter.isAlive) {
                _fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.HURT_FLY, 1);
            }
            else {
                _fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.DIE, 1);
            }

        }

        _isFalling = false;

        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT);
    }

    private function renderHurt():void {
        if (!_fighter.isAlive) {
            return;
        }
        renderHurtBreak();
    }

    /**
     *  被打反击
     */
    private function renderHurtBreak():void {

        if (!_actionCtrler.specailSkill()) {
            return;
        }

        if (!_fighter.hasEnergy(50)) {
            return;
        }
        if (_fighter.qi < 100) {
            return;
        }

        var bishaHit:Boolean = _fighter.getLastHurtHitVO().isBisha();
        if (bishaHit) {
            return;
        }

        var breakHit:Boolean = _fighter.hurtBreakHit();
        if (breakHit) {
            return;
        }

        var damage:int = _fighter.currentHurtDamage();
        if (damage > 210) {
            return;
        }

        _fighter.useQi(100);
        _fighter.useEnergy(100);

        if (_fighter.data.comicType == 1) {
            _fighter.replaceSkill();
        }
        else {
            _fighter.energyExplode();
        }

        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);

    }

    private function renderHurtAnimate():void {
//			renderBeHitGap();
        if (_hurtHoldFrame-- <= 0) {

            if (!_fighter.isAlive) {
                _action.clearState();

                if (_fighter.isInAir) {
                    var vec:Point = _fighter.getVec2();
                    hurtFly(vec.x, vec.y);
                }
                else {
                    _mc.playHurtDown();
                }

                _fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.DIE, 1);

            }
            else {
                hurtResume();
            }

//				trace("恢复被打");
        }
    }

    private function hurtResume():void {
        //当被打到空中后又落地，恢复状态时，不要再有落地动作
        if (!_fighter.isInAir && !_isTouchFloor) {
            _isTouchFloor = true;
        }
        idle();
        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
    }

    private function renderBeHitGap():void {
        if (_beHitGap > 0) {
            if (--_beHitGap <= 0) {
//					trace('isAllowBeHit');
                _fighter.isAllowBeHit = true;
            }
        }
    }

    private function doDefenseHit(hitvo:HitVO, hitRect:Rectangle):void {

        _fighter.loseHp(hitvo.getDamage() * GameConfig.DEFENSE_LOSE_HP_RATE);

        if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
            _fighter.isAlive = false;

            doHurt(hitvo, hitRect);
            return;
        }

        _fighter.defenseHit = hitvo;

        var defEnergy:int = 0;
        if (hitvo.isBreakDef) {
            defEnergy = 90;
        }
        else {
            defEnergy = hitvo.getDamage() / 5;
            if (defEnergy > 50) {
                defEnergy = 50;
            }
        }

        if (!_fighter.hasEnergy(defEnergy, false)) {
//				trace('break def');
            _fighter.useEnergy(defEnergy);
            doBreakDefense(hitvo, hitRect);
            return;
        }

        _fighter.useEnergy(defEnergy);

        _beHitGap             = GameConfig.DEFENSE_GAP_FRAME;
        _fighter.isAllowBeHit = false;

        var hitx:Number = hitvo.hitx;

        if (hitvo.owner) {
            hitx *= hitvo.owner.direct;
        }

        _action.isDefenseHiting = true;

        if (hitvo.hurtType == 0) {
            _defenseHoldFrame = int((
                                    hitvo.hurtTime / 1000
                                    ) * GameConfig.FPS_GAME / 5);
            if (_defenseHoldFrame < GameConfig.DEFENSE_HOLD_FRAME_MIN) {
                _defenseHoldFrame
                        = GameConfig.DEFENSE_HOLD_FRAME_MIN;
            }
            if (_defenseHoldFrame > GameConfig.DEFENSE_HOLD_FRAME_MAX) {
                _defenseHoldFrame
                        = GameConfig.DEFENSE_HOLD_FRAME_MAX;
            }
        }
        else {
            _defenseHoldFrame = GameConfig.DEFENSE_HOLD_FRAME_DOWN;
            _beHitGap         = GameConfig.DEFENSE_GAP_FRAME_DOWN;
        }

        _fighter.setVelocity(hitx, 0);
        _fighter.setDamping(GameConfig.DEFENSE_DAMPING_X, 0);

        if (hitvo && hitRect) {
            EffectCtrl.I.doDefenseEffect(hitvo, hitRect, _fighter.defenseType);
        }

    }

    /**
     * 破防
     */
    private function doBreakDefense(hitvo:HitVO, hitRect:Rectangle):void {
        _fighter.loseHp(hitvo.getDamage() / 10);

        if (hitvo.hurtType == 0) {
            _beHitGap = GameConfig.BREAK_DEF_GAP_FRAME;
        }
        if (hitvo.hurtType == 1) {
            _beHitGap = GameConfig.BREAK_DEF_DOWN_GAP_FRAME;
        }

        _fighter.isAllowBeHit = false;

        _fighter.energyOverLoad = false;

        _isDefense = false;

        var hitx:Number = hitvo.hitx;
//			trace('hitx',hitx);
        if (hitx < 5) {
            hitx = 5;
        }
        if (hitx > 10) {
            hitx = 10;
        }

        if (hitvo.owner) {
            hitx *= hitvo.owner.direct;
        }

//			trace('hitx2',hitx);

        _action.clearState();

        _action.isHurting = true;
        _hurtHoldFrame    = GameConfig.BREAK_DEF_HOLD_FRAME;

        _mc.goFrame(FighterSpecialFrame.HURT, true, 7);

        _fighter.actionState = FighterActionState.HURT_ING;

        _fighter.setVelocity(hitx);
        _fighter.setDamping(GameConfig.HURT_DAMPING_X);

        if (hitvo && hitRect) {
            var effectx:Number = hitRect.x + hitRect.width / 2;
            var effecty:Number = hitRect.y + hitRect.height / 2;
            EffectCtrl.I.doDefenseEffect(hitvo, hitRect, _fighter.defenseType);
            EffectCtrl.I.doEffectById('break_def', effectx, effecty, _fighter.direct);
        }
    }

    /**
     * 正在防御
     */
    private function renderDefensHiting():void {
//			renderBeHitGap();
        if (_defenseHoldFrame > 0) {
            _defenseHoldFrame--;
        }
        else {
            if (_fighter.getVecX() == 0) {
                _action.isDefenseHiting = false;
            }
        }
    }

    private function renderCheckTargetHit():void {
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
                    doAction(_action.hitTarget);
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

    /**
     * 倒地起身
     */
    private function doHurtDownJump():void {
        if (_doingAction == FighterSpecialFrame.HURT_DOWN_JUMP) {
            return;
        }
        if (_fighter.currentHurtDamage() > 240) {
            return;
        }
        if (!_fighter.hasEnergy(30)) {
            return;
        }

        _mc.stopHurtFly();

        _fighter.useEnergy(30);

        var vecx:Number = _fighter.getVecX();

        doAction(FighterSpecialFrame.HURT_DOWN_JUMP);
        _fighter.isAllowBeHit = false;
        _fighter.setVelocity(vecx);
        _fighter.setDamping(vecx * 0.1);
        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
    }

    private function doGhostStep():void {
        if (startGhostStep()) {
            move(8, 0);
            _mc.goFrame(FighterSpecialFrame.MOVE, true);
            _ghostType = 0;
        }
    }

    private function doGhostJump():void {
        if (startGhostStep()) {
            move(0, -12);
            damping(0, 0.1);
            _mc.goFrame(FighterSpecialFrame.JUMP, false);
            _action.jumpTimes--;
            _ghostType = 1;
        }
    }

    private function doGhostJumpDown():void {
        if (startGhostStep()) {
            move(0, 15);
            _mc.goFrame(FighterSpecialFrame.JUMP_DOWN, false);
            _ghostType = 2;
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
        effectCtrler.ghostStep();

        return true;
    }

    /**
     * 幽步
     */
    private function renderGhostStep():void {

        if (_ghostStepFrame-- <= 0) {
            if (_ghostType == 1) {
                var vecy:Number   = _fighter.getVecY();
                _action.isJumping = false;

                endGhostStep();

                _fighter.setVelocity(0, vecy);
                _fighter.setDamping(0, -vecy / 10);
                setAirMove(true);
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
        effectCtrler.endGhostStep();
        _fighter.getCtrler().setDirectToTarget();
        idle();
    }

}
}
