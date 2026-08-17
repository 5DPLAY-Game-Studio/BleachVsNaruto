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
import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;
import net.play5d.game.bvn.fighter.ctrler.FighterActionLogic;
import net.play5d.game.bvn.fighter.ctrler.FighterVoice;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.data.HitType;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterAction;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 受击 / 防御域：僵直、击飞、防御与破防。
 *
 * <p><code>FighterMcCtrler</code> 仍为时间轴门面；本类承接受击防御状态机。</p>
 *
 * @see FighterMcCtrler
 */
public class FighterMcHurtCtrl {

    /** @private */
    private var _owner:FighterMcCtrler;
    /** @private */
    private var _rt:FighterMcRuntime;

    /** @private 被打延时 */
    private var _hurtHoldFrame:int = 0;
    /** @private 防御延时 */
    private var _defenseHoldFrame:int = 0;
    /** @private 受攻击间隔(帧) */
    private var _beHitGap:int;
    /** @private 是否正在防御 */
    private var _isDefense:Boolean;
    /** @private */
    private var _defenseFrameDelay:int = 0;
    /** @private */
    private var _hurtDownFrame:int;
    /** @private */
    private var _justDefenseFrame:int;
    /** @private */
    private var _justHurtResume:Boolean;

    /**
     * 绑定门面。
     *
     * @param owner <code>FighterMcCtrler</code> 门面。
     * @param rt 共享运行时状态。
     * @example
     * <listing version="3.0">
     * hurtCtrl.bind(mcCtrler, runtime);
     * </listing>
     */
    public function bind(owner:FighterMcCtrler, rt:FighterMcRuntime):void {
        _owner = owner;
        _rt    = rt;
    }

    /**
     * 释放引用。
     *
     * @example
     * <listing version="3.0">
     * hurtCtrl.destroy();
     * </listing>
     */
    public function destroy():void {
        _owner = null;
        _rt    = null;
    }

    /**
     * 刚从受击恢复站立的一帧标记。
     */
    public function get justHurtResume():Boolean {
        return _justHurtResume;
    }

    /**
     * 进入 idle 时同步受击/防御相关状态。
     *
     * @param wasHurting 进入 idle 前是否处于受击态。
     * @example
     * <listing version="3.0">
     * hurtCtrl.onIdleEnter(FighterActionState.isHurting(state));
     * </listing>
     */
    public function onIdleEnter(wasHurting:Boolean):void {
        if (wasHurting) {
            _justHurtResume = true;
        }
        _justDefenseFrame = 0.1 * GameConfig.FPS_GAME;
        _isDefense        = false;
    }

    /**
     * 清除防御按住标记。
     *
     * @example
     * <listing version="3.0">
     * hurtCtrl.clearDefense();
     * </listing>
     */
    public function clearDefense():void {
        _isDefense = false;
    }

    /**
     * 击飞开始时重置倒地起身计数。
     *
     * @example
     * <listing version="3.0">
     * hurtCtrl.resetHurtDownFrame();
     * </listing>
     */
    public function resetHurtDownFrame():void {
        _hurtDownFrame = 0;
    }

    /**
     * 每逻辑帧递减刚防御窗口。
     *
     * @example
     * <listing version="3.0">
     * hurtCtrl.tickJustDefenseFrame();
     * </listing>
     */
    public function tickJustDefenseFrame():void {
        if (_justDefenseFrame > 0) {
            _justDefenseFrame--;
        }
    }

    /**
     * 动画帧开头：恢复刚受击允许受击，并推进受击间隔。
     *
     * @example
     * <listing version="3.0">
     * hurtCtrl.renderAnimatePrelude();
     * </listing>
     */
    public function renderAnimatePrelude():void {
        if (_justHurtResume) {
            _fighter.isAllowBeHit = true;
            _justHurtResume       = false;
        }
        renderBeHitGap();
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
     * 处理受击（钢身 / 防御 / 受伤）。
     *
     * @param hitVO 攻击值对象。
     * @param hitRect 攻击范围。
     */
    public function beHit(hitVO:HitVO, hitRect:Rectangle = null):void {
        if (_action.hurtAction) {
            _owner.doAction(_action.hurtAction);
            return;
        }

        var target:IGameSprite       = hitVO.owner;
        var targetBGS:BaseGameSprite =
                    (target && (target is BaseGameSprite)) ?
                    target as BaseGameSprite :
                    null;
        if (_fighter.getIsTouchSide() &&
            target &&
            targetBGS &&
            targetBGS.isAllowReversePush
        ) {
            if (Math.abs(_fighter.x - target.x) < 100) {
//                var dampingX:Number = _isDefense ?
//                                      GameConfig.DEFENSE_DAMPING_X :
//                                      (hitVO.hurtType == 1 ? 0.2 : GameConfig.HURT_DAMPING_X);
                var dampingX:Number = 0.3;
                var vecX:Number     = -hitVO.hitx * targetBGS.direct * 1.4;
                if (vecX > 20) {
                    vecX = 20;
                }
                if (vecX < -20) {
                    vecX = -20;
                }

                targetBGS.setVec2(vecX, 0, dampingX, 0);
            }
        }

//        if (_isDefense) {
//            if (hitVO.isBreakDef && hitVO.hitType == HitType.CATCH) {
//                doHurt(hitVO, hitRect);
//                return;
//            }
//
//            if (hitVO.checkDirect && hitVO.owner) {
//                if (checkDefDirect(hitVO.owner)) {
//                    doHurt(hitVO, hitRect);
//                    return;
//                }
//            }
//
//            doDefenseHit(hitVO, hitRect);
//        }
//        else {
//            if (_fighter.isSteelBody && _fighter.isAlive) {
//                doSteelHurt(hitVO, hitRect);
//            }
//            else {
//                doHurt(hitVO, hitRect);
//            }
//        }

        if (_fighter.isSteelBody) {
            if (_fighter.isAlive) {
                doSteelHurt(hitVO, hitRect);
            }
        }
        else if (_isDefense &&
                 !(hitVO.isBreakDef && hitVO.hitType == HitType.CATCH) &&
                 !(hitVO.checkDirect && hitVO.owner && checkDefDirect(hitVO.owner)))
        {
            doDefenseHit(hitVO, hitRect);
        }
        else {
            doHurt(hitVO, hitRect);
        }
    }

    /**
     * 击飞中：倒地起身窗口。
     */
    public function renderHurtFlying():void {
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

    /**
     * 防御中转向。
     *
     * @param setActions 是否重设可防御动作。
     * @param isJustDefense 是否刚进入防御。
     */
    public function renderDefense(setActions:Boolean = true, isJustDefense:Boolean = false):void {

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

    /**
     * 防御动画帧：持续按防或收招。
     */
    public function renderDefenseAnimate():void {
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
            _mc.goFrame(FighterSpecialFrame.DEFENSE_RESUME, false, 0, {call: _owner.idle, delay: 1});
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
            _owner.setSkill1();
            _owner.setZhao2();
            _owner.setBishaSUPER();
            _owner.setJumpDown();
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
    public function doDefense():void {
        if (_action.isDefensing) {
            return;
        }

        _fighter.actionState = FighterActionState.DEFENSE_ING;
        _owner.dampingPercent(1, 1);
        setDefenseAction();
    }

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

    /**
     * 执行受伤
     *
     * @param hitVO 攻击值对象
     * @param hitRect 攻击范围
     */
    private function doHurt(hitVO:HitVO, hitRect:Rectangle):void {
        if (hitVO && hitRect) {
            EffectCtrl.I.doHitEffect(hitVO, hitRect, _fighter);
        }

        _fighter.hurtHit = hitVO;
        _fighter.loseHp(hitVO.getDamage());

        _fighter.isAllowBeHit = false;
        _beHitGap             = GameConfig.HURT_GAP_FRAME;

        if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
            _fighter.isAlive = false;
            FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
        }

        if (!_fighter.isAlive || !hitVO.isWeakHit()) {
            doHurtAnimate(hitVO, hitRect);
        }

        // 受到非击飞类伤害时，根据要求设置自身是否受到重力效果
        // 当僵直结束时，角色会自动恢复重力（idle 效果）
        if (_fighter.isAlive && hitVO.hurtType == 0) {
            _fighter.isApplyG = hitVO.targetApplyG;
        }
    }

    private function doHurtAnimate(hitvo:HitVO, hitRect:Rectangle):void {
        _owner.effectCtrler.endShadow();
        _owner.effectCtrler.endShake();

        _fighter.isApplyG = true;
        _isDefense        = false;

        var hitx:Number = hitvo.hitx;
        var hity:Number = hitvo.hity;

        // 无双模式 - 小兵特殊处理
        if (_fighter.musouEnemyData && !_fighter.musouEnemyData.isBoss) {
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
        _owner.setSteelBody(false);

        if (hitvo.hurtType == 0) {
            _action.isHurting = true;
            _hurtHoldFrame    = Math.round((
                                                   hitvo.hurtTime * 0.001
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

    /**
     * 受击逻辑帧（含受击反击判定）。
     */
    public function renderHurt():void {
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

        _owner.dispatchTrainingInput(FighterInputCmd.ASSIST, true);
        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);

    }

    /**
     * 受击僵直动画帧。
     */
    public function renderHurtAnimate():void {
//			renderBeHitGap();
        if (_hurtHoldFrame-- <= 0) {

            if (!_fighter.isAlive) {
                _action.clearState();

                if (_fighter.isInAir) {
                    var vec:Point = _fighter.getVec2();
                    _owner.hurtFly(vec.x, vec.y);
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
        _owner.idle();
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
            defEnergy = _fighter.energyMax * GameConfig.ENERGY_LOSE_DEFENSE_BREAK_RATE;
        }
        else {
            defEnergy = hitvo.getDamage() * 0.2;
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
                                    hitvo.hurtTime * 0.001
                                    ) * GameConfig.FPS_GAME * 0.2);
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
        _fighter.loseHp(hitvo.getDamage() * 0.1);

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
            var effectx:Number = hitRect.x + hitRect.width * 0.5;
            var effecty:Number = hitRect.y + hitRect.height * 0.5;
            EffectCtrl.I.doDefenseEffect(hitvo, hitRect, _fighter.defenseType);
            EffectCtrl.I.doEffectById('break_def', effectx, effecty, _fighter.direct);
        }
    }

    /**
     * 正在防御
     */
    public function renderDefensHiting():void {
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

        _owner.doAction(FighterSpecialFrame.HURT_DOWN_JUMP, false, null, FighterInputCmd.DASH, true);
        _fighter.isAllowBeHit = false;
        _fighter.setVelocity(vecx);
        _fighter.setDamping(vecx * 0.1);
        FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
    }

}
}
