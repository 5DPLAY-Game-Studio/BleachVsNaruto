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

package net.play5d.game.bvn.fighter.ctrler.ai {
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterHitRange;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterAILogic extends FighterAILogicBase {

    public function FighterAILogic(AILevel:int, fighter:FighterMain) {
        super(AILevel, fighter);
    }
    public var moveLeft:Boolean;
    public var moveRight:Boolean;
    public var jump:Boolean;
    public var jumpDown:Boolean;
    public var dash:Boolean;
    public var downJump:Boolean;
    public var defense:Boolean;
    public var attack:Boolean;
    public var attackAIR:Boolean;
    public var skillAIR:Boolean;

    ////////////////////////////////////////////
    public var bishaAIR:Boolean;
    public var skill1:Boolean;
    public var skill2:Boolean;
    public var zhao1:Boolean;
    public var zhao2:Boolean;
    public var zhao3:Boolean;
    public var catch1:Boolean;
    public var catch2:Boolean;
    public var bisha:Boolean;
    public var bishaUP:Boolean;
    public var bishaSUPER:Boolean;
    public var assist:Boolean;
    public var specialSkill:Boolean;
    public var ghostStep:Boolean;
    public var ghostJump:Boolean;
    public var ghostJumpDowm:Boolean;
    private var _moveKeep:Number      = 40;
    private var _catchMoveKeep:Number = 15;
    private var _dashKeep:Number      = 200;
    private var _jumpKeep:Number      = 50;
    private var _moveFrame:int;
    private var _defenseFrame:int;
    /** @private getAIByFighterState 复用表 */
    private var _rateObj:Object = {};

    /** @private AI 概率表（静态复用，勿就地改写元素） */
    private static const R0:Array      = [0, 0, 0, 0, 0, 0];
    private static const R_DJ:Array    = [0, 0, 0.2, 1, 3, 5];
    private static const R_MV:Array    = [3, 5, 7, 8, 9, 10];
    private static const R_MV_ATK:Array = [2, 4, 5, 3, 1, 0];
    private static const R_MV_SK:Array = [2, 4, 3, 2, 0, 0];
    private static const R_MV_BS:Array = [2, 1, 0, 0, 0, 0];
    private static const R_JP_C:Array  = [1, 2, 3, 2, 1, 0];
    private static const R_JP_CH:Array = [0, 1, 2, 3, 3, 4];
    private static const R_JP_UP:Array = [2, 3, 4, 5, 6, 6];
    private static const R_JP_LO:Array = [0.01, 0, 0, 0, 0, 0];
    private static const R_JP_LB:Array = [0.02, 0, 0, 0, 0, 0];
    private static const R_DSH1:Array  = [0, 0, 0.1, 0.5, 0, 0];
    private static const R_DSH2:Array  = [0, 0.05, 0.3, 1, 0, 0];
    private static const R_DSH3:Array  = [0, 0, 0.05, 0, 0, 0];
    private static const R_DSH4:Array  = [0.5, 1, 2, 5, 7, 9];
    private static const R_DSH5:Array  = [0, 0, 0.1, 3, 1, 0];
    private static const R_DSH6:Array  = [0, 0, 0.05, 1, 0, 0];
    private static const R_DSH7:Array  = [0, 0, 0.05, 0.1, 0, 0];
    private static const R_DEF_C:Array = [10, 10, 10, 10, 10, 10];
    private static const R_DEF_F:Array = [5, 4, 4, 3, 2, 1];
    private static const R_DEF_N:Array = [2, 1, 1, 0, 0, 0];
    private static const R_DEF_N2:Array = [0.5, 1, 3, 5, 7, 9];
    private static const R_DEF_F2:Array = [0.5, 1, 3, 2, 1, 0];
    private static const R_DEF_SK:Array = [1, 3, 5, 7, 9, 10];
    private static const R_DEF_BS:Array = [2, 4, 6, 8, 10, 10];
    private static const R_ATK_C:Array = [1, 2, 3, 6, 9, 10];
    private static const R_ATK_D:Array = [0.5, 1, 4, 6, 8, 10];
    private static const R_ATK_DF:Array = [0.5, 1, 3, 2, 2, 1];
    private static const R_ATK_HA:Array = [0.5, 1, 1, 0.5, 0, 0];
    private static const R_ATK_A:Array = [0.5, 1, 1, 0, 0, 0];
    private static const R_SK_B1:Array = [0.1, 0.2, 0.5, 3, 6, 10];
    private static const R_SK_B2:Array = [0, 0.2, 0.5, 2, 1, 0];
    private static const R_SK_B3:Array = [0, 0.2, 0.7, 5, 7, 9];
    private static const R_SK_B4:Array = [0.1, 0.2, 0.5, 1, 2, 2];
    private static const R_SK_N1:Array = [0, 0, 0.1, 1, 5, 10];
    private static const R_SK_N2:Array = [0.1, 0.5, 1, 3, 2, 0.2];
    private static const R_SK_N3:Array = [0, 0, 1, 1, 0, 0];
    private static const R_SK_HA:Array = [0.5, 1, 0.5, 0, 0, 0];
    private static const R_SK_AT:Array = [0, 0, 0, 1, 1, 2];
    private static const R_BS_B1:Array = [0, 0, 0.3, 2, 5, 10];
    private static const R_BS_B2:Array = [0.1, 0.2, 0.5, 2, 2, 2];
    private static const R_BS_B3:Array = [0, 0, 0.5, 3, 7, 9];
    private static const R_BS_B4:Array = [0.1, 0.2, 1, 6, 8, 10];
    private static const R_BS_N1:Array = [0, 0, 0.5, 4, 8, 10];
    private static const R_BS_N2:Array = [0.2, 0.5, 1, 2, 2, 0];
    private static const R_BS_H:Array  = [0.2, 0.5, 1, 3, 5, 6];
    private static const R_BS_J:Array  = [0.2, 0.5, 1, 3, 4, 4];
    private static const R_BS_D1:Array = [0.2, 0.5, 1, 3, 2, 1];
    private static const R_BS_D2:Array = [0.2, 0.5, 1, 2, 1, 0];
    private static const R_BS_HA:Array = [0.2, 0.5, 0, 0, 0, 0];
    private static const R_BS_AT:Array = [0, 0.2, 0.5, 2, 1, 1];
    private static const R_BS_SK:Array = [0, 0, 0.1, 0, 0, 0];
    private static const R_CA_N:Array  = [0, 0.5, 1, 3, 2, 1];
    private static const R_CA_D:Array  = [1, 2, 4, 5, 7, 10];
    private static const R_CA_NF:Array = [0, 0.5, 1, 0, 0, 0];
    private static const R_CA_DF:Array = [1, 2, 3, 4, 3, 2];
    private static const R_BRK:Array   = [0, 0, 0, 0, 0.1, 0.2];
    private static const R_BRK_S:Array = [0, 0, 0, 0, 0.2, 0.4];
    private static const R_CALL:Array  = [0, 0.02, 0.05, 0.05, 0, 0];
    private static const R_CALL_D:Array = [0, 0.02, 0.05, 0.1, 0.3, 0.5];
    private static const R_GS:Array    = [0, 0, 0, 0, 0.1, 0.2];
    private static const R_GS_J:Array  = [0, 0, 0.1, 0.1, 0.1, 0.1];
    private static const R_GS_D:Array  = [0, 0, 0, 0.1, 0.1, 0.1];

    /**
     * @private 清空并返回复用 AI 概率表。
     */
    private function beginRateObj():Object {
        for (var k:String in _rateObj) {
            delete _rateObj[k];
        }
        return _rateObj;
    }

    public override function render():void {
        super.render();
        if (!_fighter || !_target) {
            return;
        }
        updateMoveAI();
        updateJumpAI();
        updateJumpDownAI();
        updateHurtAI();
        updateDefenseAI();
        updateSpecialSkill();
        updateGhostStep();
    }

//		public override function onDoAction():void{
//			super.onDoAction();
//			if(!_fighter || !_target) return;
//
//			updateDashAI();
//
//			updateAttackAI();
//			updateSkill();
//			updateBisha();
//
//			updateCache();
//		}

    protected override function updateActionAI():void {
        updateDashAI();

        updateAttackAI();
        updateSkill();
        updateBisha();

        updateCache();

        updateAssist();
    }

    public function updateBisha():void {
        bisha      = _fighterAction.bisha && getBishaAI('bisha', 'bs', FighterHitRange.BISHA, 100, 100);
        bishaUP    = _fighterAction.bishaUP && getBishaAI('bishaUP', 'sbs', FighterHitRange.BISHA_UP, 100, 100);
        bishaSUPER = _fighterAction.bishaSUPER &&
                     getBishaAI('bishaSUPER', 'cbs', FighterHitRange.BISHA_SUPER, 300, 200);
        bishaAIR   = _fighterAction.bishaAIR && getBishaAI('bishaAIR', 'kbs', FighterHitRange.BISHA_AIR, 100, 210);
    }

    private function updateHurtAI():void {
        downJump = false;

        var downJumpObj:Object                    = beginRateObj();
        downJumpObj['defult']                     = R_DJ;
        downJumpObj[FighterActionState.SKILL_ING] = R0;
        downJumpObj[FighterActionState.BISHA_ING] = downJumpObj[FighterActionState.BISHA_SUPER_ING] = R0;

        downJump = getAIByFighterState(downJumpObj);

    }

    private function updateMoveAI():void {
        moveLeft  = false;
        moveRight = false;

        var isDefensing:Boolean = _fighter.actionState == FighterActionState.DEFENSE_ING;

        if (isDefensing) {
            var defenseMove:Boolean = getAIResult(1, 2, 4, 5, 6, 8);
            if (defenseMove) {
                if (_fighter.x > _target.x + 20) {
                    moveLeft = true;
                }
                if (_fighter.x < _target.x - 20) {
                    moveRight = true;
                }
            }
            return;
        }


        var moving:Boolean;
        if (_moveFrame < GameConfig.FPS_GAME) {
            _moveFrame++;
            moving = true;
        }
        else {
            var moveObj:Object                     = beginRateObj();
            moveObj['defult']                      = R_MV;
            moveObj[FighterActionState.ATTACK_ING] = R_MV_ATK;
            moveObj[FighterActionState.SKILL_ING]  = R_MV_SK;
            moveObj[FighterActionState.BISHA_ING]  = moveObj[FighterActionState.BISHA_SUPER_ING] = R_MV_BS;
            moving                                 = getAIByFighterState(moveObj);
            if (moving) {
                _moveFrame = 0;
            }
        }

        if (moving) {

            var isCatch:Boolean = (
                                          catch1 || catch2
                                  ) && (
                                          Math.abs(_fighter.y - _target.y) < 2
                                  );

            var moveKeep:Number = isCatch ? _catchMoveKeep : _moveKeep;

            if (_fighter.x > _target.x + moveKeep) {
                moveLeft = true;
            }

            if (_fighter.x < _target.x - moveKeep) {
                moveRight = true;
            }

        }

        if (!moveLeft && !moveRight) {
            _moveFrame = GameConfig.FPS_GAME;
//				if(_fighter.direct == _target.direct){
//					if(_fighter.x > _target.x){
//						moveLeft = true;
//					}else{
//						moveRight = true;
//					}
//				}
        }

    }

    private function updateJumpAI():void {
        var jumpObj:Object = beginRateObj();

        if (_isConting) {
            jumpObj['defult']                    = R_JP_C;
            jumpObj[FighterActionState.HURT_ING] = R_JP_CH;
        }
        else {
            if (_fighter.y > _target.y + _jumpKeep) {
                jumpObj['defult']                     = R_JP_UP;
                jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = R_MV_BS;
            }
            else {
                jumpObj['defult']                     = R_JP_LO;
                jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = R_JP_LB;
            }
        }

        jump = getAIByFighterState(jumpObj);

        if (_isConting && jump) {
            addContOrder('jump', 10);
        }
    }

    private function updateJumpDownAI():void {
        var jumpObj:Object = beginRateObj();

        if (_fighter.y < _target.y - _jumpKeep) {
            jumpObj['defult']                     = R_JP_UP;
            jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = R_MV_BS;
        }
        else {
            jumpObj['defult']                     = R_JP_LO;
            jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = R_JP_LB;
        }

        jumpDown = getAIByFighterState(jumpObj);
    }

    private function updateDashAI():void {
        var dashObj:Object = beginRateObj();

        var dis:Number    = getTargetDistance(_target).x;
        var direct:Number = _target.x > _fighter.x ? 1 : -1;

        if (_fighter.energy < 40) {
            if (dis > _dashKeep && _fighter.direct == direct) {
                dashObj['defult']                      = R_DSH1;
                dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] = R_DSH2;
                dashObj[FighterActionState.BISHA_ING]  = dashObj[FighterActionState.BISHA_SUPER_ING] = R0;
            }
            else {
                dashObj['defult']                      = R_DSH3;
                dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] =
                        dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = R0;
            }
        }
        else {
            if (dis > _dashKeep && _fighter.direct != _target.direct) {
                dashObj['defult']                      = R_DSH4;
                dashObj[FighterActionState.ATTACK_ING] = R_DSH5;
                dashObj[FighterActionState.SKILL_ING]  = R_DSH6;
                dashObj[FighterActionState.BISHA_ING]  = dashObj[FighterActionState.BISHA_SUPER_ING] = R0;
            }
            else {
                dashObj['defult']                      = R_DSH7;
                dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] =
                        dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = R0;
            }
        }

        dash = getAIByFighterState(dashObj);
    }

    private function updateDefenseAI():void {

//			if(defense){
//				if(_defenseFrame > 0){
//					_defenseFrame--;
//					return;
//				}else{
//					_defenseFrame = GameConfig.FPS_GAME;
//				}
//			}


        if (defense) {
            var ctobj:Object                      = beginRateObj();
            ctobj['defult']                       = R_DEF_C;
            ctobj[FighterActionState.FREEZE]      = R_DEF_F;
            ctobj[FighterActionState.NORMAL]      = R_DEF_N;
            ctobj[FighterActionState.HURT_ING]    = R0;
            ctobj[FighterActionState.HURT_FLYING] = R0;
            ctobj[FighterActionState.HURT_DOWN]   = R0;
            defense                               = getAIByFighterState(ctobj);
            if (defense) {
                return;
            }
        }


        var distance:Point = getTargetDistance(_target);

        var resultObj:Object = beginRateObj();


        resultObj['defult'] = R0;
        if (distance.x < 100 && distance.y < 100) {
            resultObj[FighterActionState.ATTACK_ING] = R_DEF_N2;
        }
        else {
            resultObj[FighterActionState.ATTACK_ING] = R_DEF_F2;
        }
        resultObj[FighterActionState.SKILL_ING] = R_DEF_SK;
        resultObj[FighterActionState.BISHA_ING] = resultObj[FighterActionState.BISHA_SUPER_ING] = R_DEF_BS;
        defense                                 = getAIByFighterState(resultObj);

        if (defense) {
            return;
        }

        var targets:Vector.<IGameSprite> = _fighter.getTargets();

        for each(var i:IGameSprite in targets) {
            if (i == _target) {
                continue;
            }
            if (i is Bullet && (
                    i as Bullet
            ).isAttacking()) {
                var dis:Point = getTargetDistance(i);
                if (dis.x < 200 && dis.y < 150) {
                    defense = getAIResult(2, 4, 5, 7, 9, 10);
                }
                else {
                    defense = getAIResult(2, 4, 5, 5, 2, 1);
                }
                if (defense) {
                    return;
                }
            }
            if (i is FighterAttacker && (
                    i as FighterAttacker
            ).isAttacking) {
                defense = getAIResult(2, 4, 5, 7, 9, 10);
                if (defense) {
                    return;
                }
            }
            if (i is Assister && (
                    i as Assister
            ).isAttacking) {
                defense = getAIResult(2, 4, 6, 8, 10, 10);
                if (defense) {
                    return;
                }
            }
        }

    }

    private function updateAttackAI():void {
        attack    = false;
        attackAIR = false;

        if (!_fighterAction.attack && !_fighterAction.attackAIR) {
            return;
        }
        if (!targetCanBeHit()) {
            return;
        }

        var attackObj:Object                       = beginRateObj();
        attackObj.defult                           = _isConting ? R_ATK_C : R_ATK_D;
        attackObj[FighterActionState.DEFENSE_ING]  = R_ATK_DF;
        attackObj[FighterActionState.HURT_ACT_ING] = R_ATK_HA;
        attackObj[FighterActionState.ATTACK_ING]   = R_ATK_A;
        attackObj[FighterActionState.SKILL_ING]    =
                attackObj[FighterActionState.BISHA_ING] =
                        attackObj[FighterActionState.BISHA_SUPER_ING] = R0;


        var result:Boolean = getAIByFighterState(attackObj);
        if (!result) {
            return;
        }

        var order:int = 10;

        if (_isConting) {
            attack    = true;
            attackAIR = _fighter.y < _target.y;

            var curAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();

            if (curAction == FighterSpecialFrame.ATTACK) {
                order = 200;
            }

        }
        else {
            attack    = targetInRange(FighterHitRange.ATTACK);
            attackAIR = targetInRange(FighterHitRange.ATTACK_AIR) && _fighter.y < _target.y;
            order     = 300;
        }

        if (attack) {
            addContOrder('attack', order);
        }
        if (attackAIR) {
            addContOrder('attackAIR', order);
        }

    }

    private function updateSkill():void {

        skill1 = _fighterAction.skill1 && getSkillAI('skill1', 'kj1', FighterHitRange.SKILL_1, 10);
        skill2 = _fighterAction.skill2 && getSkillAI('skill2', 'kj2', FighterHitRange.SKILL_2, 10);

        zhao1 = _fighterAction.zhao1 && getSkillAI('zhao1', 'zh1', FighterHitRange.ZHAO_1, 10);
        zhao2 = _fighterAction.zhao2 && getSkillAI('zhao2', 'zh2', FighterHitRange.ZHAO_2, 10);
        zhao3 = _fighterAction.zhao3 && getSkillAI('zhao3', 'zh3', FighterHitRange.ZHAO_3, 10);

        skillAIR = _fighterAction.skillAIR && getSkillAI('skillAIR', 'tz', FighterHitRange.SKILL_AIR, 10);
    }

    private function getSkillAI(id:String, hitId:String, range:String, order:int):Boolean {
        var skillObj:Object = beginRateObj();
        var result:Boolean  = false;

        if (isBreakAct(hitId)) {
            skillObj.defult                          = _isConting ? R_SK_B1 : R_SK_B2;
            skillObj[FighterActionState.DEFENSE_ING] = _isConting ? R_SK_B3 : R_SK_B4;
        }
        else {
            skillObj.defult                          = _isConting ? R_SK_N1 : R_SK_N2;
            skillObj[FighterActionState.DEFENSE_ING] = R_SK_N3;
        }

        skillObj[FighterActionState.HURT_ACT_ING] = R_SK_HA;
        skillObj[FighterActionState.ATTACK_ING]   = R_SK_AT;
        skillObj[FighterActionState.SKILL_ING]    =
                skillObj[FighterActionState.BISHA_ING] =
                        skillObj[FighterActionState.BISHA_SUPER_ING] = R0;

        result = getAIByFighterState(skillObj) && targetCanBeHit() && targetInRange(range);

        if (result) {
            if (_isConting) {
                addContOrder(id, isHitDownAct(hitId) ? order : order + 100);
            }
        }

        return result;
    }

    private function getBishaAI(id:String, hitId:String, range:String, qi:int, order:int):Boolean {
        var bishaObj:Object = beginRateObj();
        var result:Boolean  = false;

        if (_fighter.qi >= qi) {
            if (isBreakAct(hitId)) {
                bishaObj.defult                          = _isConting ? R_BS_B1 : R_BS_B2;
                bishaObj[FighterActionState.DEFENSE_ING] = _isConting ? R_BS_B3 : R_BS_B4;
            }
            else {
                bishaObj.defult                          = _isConting ? R_BS_N1 : R_BS_N2;
                bishaObj[FighterActionState.HURT_ING]    = R_BS_H;
                bishaObj[FighterActionState.JUMP_ING]    = R_BS_J;
                bishaObj[FighterActionState.DEFENSE_ING] = _isConting ? R_BS_D1 : R_BS_D2;
            }

            bishaObj[FighterActionState.HURT_ACT_ING] = R_BS_HA;
            bishaObj[FighterActionState.ATTACK_ING]   = R_BS_AT;
            bishaObj[FighterActionState.SKILL_ING]    =
                    bishaObj[FighterActionState.BISHA_ING] =
                            bishaObj[FighterActionState.BISHA_SUPER_ING] = R_BS_SK;

            result = getAIByFighterState(bishaObj) && targetCanBeHit() && targetInRange(range);
        }

        if (result) {
            if (_isConting) {
                addContOrder(id, order);
            }
        }

        return result;
    }

    private function updateCache():void {
        catch1 = false;
        catch2 = false;


        var cacheObj:Object = beginRateObj();
        if (_targetFighter && (
                _targetFighter.actionState == FighterActionState.HURT_ING ||
                _targetFighter.actionState == FighterActionState.HURT_FLYING ||
                _targetFighter.actionState == FighterActionState.HURT_DOWN
        )) {
            return;
        }

        var dis:Point = getTargetDistance(_target);
        if (dis.x < 50) {
            cacheObj.defult                          = R_CA_N;
            cacheObj[FighterActionState.DEFENSE_ING] = R_CA_D;
        }
        else {
            cacheObj.defult                          = R_CA_NF;
            cacheObj[FighterActionState.DEFENSE_ING] = R_CA_DF;
        }

        catch1 = getAIByFighterState(cacheObj) && targetCanBeHit();
        catch2 = getAIByFighterState(cacheObj) && targetCanBeHit();

        if (catch1) {
            addContOrder('catch1', 150);
        }
        if (catch2) {
            addContOrder('catch2', 110);
        }

    }


    private function updateSpecialSkill():void {

        if (_fighter.actionState == FighterActionState.HURT_ING) {

            if (_fighter.hp > _fighter.hpMax * 0.6) {
                return;
            }
            if (_fighter.qi < 150) {
                return;
            }

            //被打反击
            var breakObj:Object                    = beginRateObj();
            breakObj.defult                        = R_BRK;
            breakObj[FighterActionState.SKILL_ING] = R_BRK_S;
            specialSkill                           = getAIByFighterState(breakObj);
        }
    }

    private function updateAssist():void {
        //招唤
        var callObj:Object                      = beginRateObj();
        callObj.defult                          = R_CALL;
        callObj[FighterActionState.DEFENSE_ING] = R_CALL_D;
//			callObj[FighterActionState.ATTACK_ING] = [0,0,0,1,2,2];
//			callObj[FighterActionState.SKILL_ING] = [0,0,0,1,1,1];
        callObj[FighterActionState.BISHA_ING]       = R0;
        callObj[FighterActionState.BISHA_SUPER_ING] = R0;
        assist                                      = getAIByFighterState(callObj);
    }

    private function updateGhostStep():void {

        var dis:Point = getTargetDistance(_target);

        if (dis.x > 80 || dis.y > 80) {
            return;
        }
        if (_fighter.qi < 200) {
            return;
        }

        if (_fighter.actionState != FighterActionState.ATTACK_ING && _fighter.actionState !=
            FighterActionState.SKILL_ING) {
            return;
        }

        var ghostStepObj:Object                   = beginRateObj();
        ghostStepObj.defult                       = R0;
        ghostStepObj[FighterActionState.HURT_ING] = R_GS;

        ghostStep = getAIByFighterState(ghostStepObj);

        if (_target.y - _fighter.y < -80 && _target.y - _fighter.y > -100) {
            var ghostJumpObj:Object                   = beginRateObj();
            ghostJumpObj.defult                       = R0;
            ghostJumpObj[FighterActionState.HURT_ING] = R_GS_J;
            ghostJump                                 = getAIByFighterState(ghostJumpObj);
        }
        else {
            ghostJump = false;
        }

        if (_target.y - _fighter.y < 80 && _target.y - _fighter.y > 100) {
            var ghostDwonObj:Object                   = beginRateObj();
            ghostDwonObj.defult                       = R0;
            ghostDwonObj[FighterActionState.HURT_ING] = R_GS_D;
            ghostJumpDowm                             = getAIByFighterState(ghostDwonObj);
        }
        else {
            ghostJumpDowm = false;
        }

    }

}
}
