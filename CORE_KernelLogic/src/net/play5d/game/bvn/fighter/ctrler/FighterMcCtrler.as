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
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterMcCtrler {

    public function FighterMcCtrler(fighter:FighterMain) {
//			_mc = mc;
        _fighter     = fighter;
        _actionLogic = new FighterActionLogic(fighter);
        _hurtCtrl   = new FighterMcHurtCtrl();
        _hurtCtrl.bind(this);
        _actionCtrl = new FighterMcActionCtrl();
        _actionCtrl.bind(this);
    }
    public var effectCtrler:FighterEffectCtrl;
    /** @private 受击/防御域 */
    private var _hurtCtrl:FighterMcHurtCtrl;
    /** @private 动作渲染域 */
    private var _actionCtrl:FighterMcActionCtrl;
    private var _actionCtrler:IFighterActionCtrl; //角色操作控制
    private var _mc:FighterMC; //角色SWF中的MC元件控制
    private var _fighter:FighterMain; //角色SWF主类
    private var _action:FighterAction = new FighterAction(); //动作定义
    private var _doingAction:String; //当前动作
    private var _doingAirAction:String; //当前空中动作
    private var _isFalling:Boolean; //是否正在落下
    private var _isTouchFloor:Boolean = true;//是否已经在地上
    private var _actionLogic:FighterActionLogic;

    public function destroy():void {
        if (_actionCtrl) {
            _actionCtrl.destroy();
            _actionCtrl = null;
        }
        if (_hurtCtrl) {
            _hurtCtrl.destroy();
            _hurtCtrl = null;
        }
        if (_actionCtrler) {
            _actionCtrler.destroy();
            _actionCtrler = null;
        }
        if (_mc) {
            _mc.destroy();
            _mc = null;
        }
        _fighter     = null;
        _action      = null;
        effectCtrler = null;
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
     * 角色主类（供 HurtCtrl / ActionCtrl 使用）。
     */
    public function getFighter():FighterMain {
        return _fighter;
    }

    /**
     * 动作判定逻辑（供 HurtCtrl / ActionCtrl 使用）。
     */
    public function getActionLogic():FighterActionLogic {
        return _actionLogic;
    }

    /**
     * 受击域（供 ActionCtrl 调用防御等）。
     */
    public function getHurtCtrl():FighterMcHurtCtrl {
        return _hurtCtrl;
    }

    /**
     * 是否已贴地（供 HurtCtrl / ActionCtrl 读写）。
     */
    public function get isTouchFloorFlag():Boolean {
        return _isTouchFloor;
    }

    /** @private */
    public function set isTouchFloorFlag(v:Boolean):void {
        _isTouchFloor = v;
    }

    /**
     * 是否正在下落（供 HurtCtrl / ActionCtrl 读写）。
     */
    public function get isFallingFlag():Boolean {
        return _isFalling;
    }

    /** @private */
    public function set isFallingFlag(v:Boolean):void {
        _isFalling = v;
    }

    /**
     * 当前动作名（供 HurtCtrl 读写）。
     */
    public function get doingActionName():String {
        return _doingAction;
    }

    /** @private */
    public function set doingActionName(v:String):void {
        _doingAction = v;
    }

    /**
     * 当前空中动作名（供 HurtCtrl 读写）。
     */
    public function get doingAirActionName():String {
        return _doingAirAction;
    }

    /** @private */
    public function set doingAirActionName(v:String):void {
        _doingAirAction = v;
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
        _mc.initialize(source, _fighter, this);
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

    /**
     * 恢复站立
     *
     * @param frame 帧名
     * @param isIgnoreAlive 是否忽略存活条件
     */
    public function idle(frame:String = null, isIgnoreAlive:Boolean = false):void {
        frame ||= FighterSpecialFrame.IDLE;

        if (!_fighter.isAlive && !isIgnoreAlive) {
            trace('not alive!!!');
            return;
        }

        _hurtCtrl.onIdleEnter(FighterActionState.isHurting(_fighter.actionState));

        endAct();
        _doingAction    = null;
        _doingAirAction = null;

        setSteelBody(false);

        effectCtrler.endShadow();
        effectCtrler.endShake();

        _action.clearAction();
        _action.clearState();

        _fighter.actionState  = FighterActionState.NORMAL;
        _fighter.isAllowBeHit = !_hurtCtrl.justHurtResume;
        _fighter.isApplyG     = true;
        _fighter.isCross      = false;
        _fighter.hurtHit      = null;
        _fighter.defenseHit   = null;
        _fighter.clearHurtHits();
        _fighter.getDisplay().visible = true;

        _actionCtrl.resetAutoDirect();

//			if(_doingAirAction){
//			if(_fighter.isInAir){
        if (!_isTouchFloor && _fighter.isInAir) {
            _actionCtrl.fall();
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
        _fighter.dispatchEvent(new FighterEvent(FighterEvent.IDLE));
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
    public function setJump(action:String = null):void {
        action ||= FighterSpecialFrame.JUMP;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jump = action;
    }

    //设定跳2
    public function setJumpQuick(action:String = null):void {
        action ||= FighterSpecialFrame.JUMP;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jumpQuick = action;
    }

    //设定从空中的板中跳下
    public function setJumpDown(action:String = null):void {
        action ||= FighterSpecialFrame.JUMP_DOWN;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.jumpDown = action;
    }

    //设定冲刺
    public function setDash(action:String = null):void {
        action ||= FighterSpecialFrame.DASH;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.dash = action;
    }

    //设定普通攻击J  parent.$mc_ctrler.setAttack("砍1");
    public function setAttack(action:String = null):void {
        action ||= FighterSpecialFrame.ATTACK;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.attack = action;
    }

    //设定技能攻击S+J
    public function setSkill1(action:String = null):void {
        action ||= FighterSpecialFrame.SKILL_1;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skill1 = action;
    }

    //设定技能攻击W+J
    public function setSkill2(action:String = null):void {
        action ||= FighterSpecialFrame.SKILL_2;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skill2 = action;
    }

    //设定技能攻击U  parent.$mc_ctrler.setZhao1();
    public function setZhao1(action:String = null):void {
        action ||= FighterSpecialFrame.ZHAO_1;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao1 = action;
    }

    //设定技能攻击S+U  parent.$mc_ctrler.setZhao2();
    public function setZhao2(action:String = null):void {
        action ||= FighterSpecialFrame.ZHAO_2;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao2 = action;
    }

    //设定技能攻击W+U  parent.$mc_ctrler.setZhao3();
    public function setZhao3(action:String = null):void {
        action ||= FighterSpecialFrame.ZHAO_3;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.zhao3 = action;
    }

    public function setCatch1(action:String = null):void {
        action ||= FighterSpecialFrame.CATCH_1;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.catch1 = action;
    }

    public function setCatch2(action:String = null):void {
        action ||= FighterSpecialFrame.CATCH_2;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.catch2 = action;
    }

    //设定必杀I  parent.$mc_ctrler.setBisha();
    public function setBisha(action:String = null, qi:int = 100):void {
        action ||= FighterSpecialFrame.BISHA;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bisha   = action;
        _action.bishaQi = qi;
    }

    //设定必杀W+I
    public function setBishaUP(action:String = null, qi:int = 100):void {
        action ||= FighterSpecialFrame.BISHA_UP;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaUP   = action;
        _action.bishaUPQi = qi;
    }

    //设定必杀S+I
    public function setBishaSUPER(action:String = null, qi:int = 300):void {
        action ||= FighterSpecialFrame.BISHA_SUPER;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaSUPER   = action;
        _action.bishaSUPERQi = qi;
    }

    //设定空中普通攻击J
    public function setAttackAIR(action:String = null):void {
        action ||= FighterSpecialFrame.ATTACK_AIR;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.attackAIR = action;
    }

    //设定空中技能U
    public function setSkillAIR(action:String = null):void {
        action ||= FighterSpecialFrame.SKILL_AIR;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.skillAIR = action;
    }

    //设定空中必杀I
    public function setBishaAIR(action:String = null, qi:int = 100):void {
        action ||= FighterSpecialFrame.BISHA_AIR;

        if (!_mc.checkFrame(action)) {
            return;
        }
        _action.bishaAIR   = action;
        _action.bishaAIRQi = qi;
    }

    //设定落地的动作,breakAct:接触到地面时是否中断当前动作
    public function setTouchFloor(action:String = null, breakAct:Boolean = true):void {
        action ||= FighterSpecialFrame.JUMP_TOUCH_FLOOR;

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
        _actionCtrl.clearMoveTarget();
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
        _hurtCtrl.resetHurtDownFrame();
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
        _actionCtrl.setMoveTarget(params);
    }

    //-----------------------------------------------------------------------------------------------
    //   帧调用方法结束  ===============================================================================
    //-----------------------------------------------------------------------------------------------

    public function render():void {

        if (_actionCtrl.ghostStepIng) {
            return;
        }

        _hurtCtrl.tickJustDefenseFrame();

        _action.render();

        if (_actionCtrl.hasMoveTarget) {
            _actionCtrl.renderMoveTarget();
        }

        if (_actionCtrler) {
            _actionCtrler.render();
        }

//			renderAssist();

        if (_action.isHurtFlying) {
            _hurtCtrl.renderHurtFlying();
            return;
        }

        if (_action.isHurting) {
            _hurtCtrl.renderHurt();
            return;
        }

        if (_action.isDefenseHiting) {
            _hurtCtrl.renderDefense(false, true);
            return;
        }

        if (_action.hitTarget) {
            _actionCtrl.renderCheckTargetHit();
        }
        if (_actionCtrl.renderWanKaiCtrl()) {
            return;
        }

        if ((
                    _fighter && _fighter.isInAir
            ) || (
                    _doingAirAction && !_action.touchFloorBreakAct
            )) {
            _actionCtrl.renderAirAction();
        }
        else {
            _actionCtrl.renderFloorAction();
        }

    }

    public function renderAnimate():void {

        _hurtCtrl.renderAnimatePrelude();

        if (_mc) {
            _mc.renderAnimate();
        }

        if (_actionCtrler) {
            _actionCtrler.renderAnimate();
        }

        if (_actionCtrl.ghostStepIng) {
            _actionCtrl.renderGhostStep();
            return;
        }

        if (_action) {
            if (_action.isHurting) {
                _hurtCtrl.renderHurtAnimate();
            }
            if (_action.isDefenseHiting) {
                _hurtCtrl.renderDefensHiting();
            }

            if (_action.isJumping) {
                _actionCtrl.renderJumpAnimate();
            }

            _actionCtrl.tickDoActionFrame();
            if (_action.isDefensing) {
                _hurtCtrl.renderDefenseAnimate();
            }
        }

        _actionCtrl.tickAutoDirect();
    }

    /**
     * 落地
     */
    public function touchFloor():void {
        _actionCtrl.touchFloor();
    }

    /**
     * 正在跳
     */
    public function renderJumpAnimate():void {
        _actionCtrl.renderJumpAnimate();
    }

    /**
     * 被打
     *
     * @param hitVO 攻击值对象
     * @param hitRect 攻击范围
     */
    public function beHit(hitVO:HitVO, hitRect:Rectangle = null):void {
        _hurtCtrl.beHit(hitVO, hitRect);
    }

    /**
     * 开场
     */
    public function sayIntro():void {
        _fighter.actionState = FighterActionState.KAI_CHANG;
        _mc.goFrame(FighterSpecialFrame.SAY_INTRO);
    }

    /**
     * 胜利
     */
    public function doWin():void {
        _fighter.actionState = FighterActionState.WIN;
        _mc.goFrame(FighterSpecialFrame.WIN);
    }

    /**
     * 失败
     */
    public function doLose():void {
        _fighter.actionState = FighterActionState.LOSE;
        _mc.goFrame(FighterSpecialFrame.LOSE);
    }

    /**
     * 执行动作
     *
     * @param action 动作帧标签。
     * @param airAct 是否为空中动作。
     * @param delayParam 跳转延迟参数。
     * @param inputText 练习模式输入历史指令串（与帧标签无关，如 <code>WJ</code>）。
     * @param highlight 是否使用菜单选中同款红色高亮。
     */
    public function doAction(
            action:String, airAct:Boolean = false, delayParam:Object = null, inputText:String = null,
            highlight:Boolean                                                                 = false
    ):void {

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

        _hurtCtrl.clearDefense();

        _fighter.isAllowBeHit = true;
        _fighter.isCross      = false;
        _fighter.isApplyG     = true;

        _actionCtrl.resetDoActionFrame();
        _mc.goFrame(action, true, 0, delayParam);

        var actEvt:FighterEvent = new FighterEvent(FighterEvent.DO_ACTION);
        actEvt.params           = {action: action, input: inputText, highlight: highlight};
        _fighter.dispatchEvent(actEvt);
    }

    /**
     * @private 向练习模式输入历史派发指令（不切换动作帧）。
     * @param highlight 是否使用菜单选中同款红色高亮。
     */
    public function dispatchTrainingInput(inputText:String, highlight:Boolean = false):void {
        if (!inputText) {
            return;
        }
        var actEvt:FighterEvent = new FighterEvent(FighterEvent.DO_ACTION);
        actEvt.params           = {input: inputText, highlight: highlight};
        _fighter.dispatchEvent(actEvt);
    }

}
}
