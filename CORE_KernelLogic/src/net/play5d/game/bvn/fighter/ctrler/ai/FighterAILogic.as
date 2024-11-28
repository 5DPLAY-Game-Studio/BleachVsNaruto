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

package net.play5d.game.bvn.fighter.ctrler.ai
{
	import flash.geom.Point;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.Bullet;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterAttacker;
	import net.play5d.game.bvn.fighter.data.FighterHitRange;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class FighterAILogic extends FighterAILogicBase
	{
		include '../../../../../../../../include/_INCLUDE_OVERRIDE_.as';

		public var moveLeft:Boolean;
		public var moveRight:Boolean;

		public var jump:Boolean;
		public var jumpDown:Boolean;

		public var dash:Boolean;

		public var downJump:Boolean;

		public var defense:Boolean;

		private var _moveKeep:Number = 40;
		private var _catchMoveKeep:Number = 15;
		private var _dashKeep:Number = 200;
		private var _jumpKeep:Number = 50;

		////////////////////////////////////////////

		public var attack:Boolean;

		public var attackAIR:Boolean;
		public var skillAIR:Boolean;
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

		private var _moveFrame:int;
		private var _defenseFrame:int;

		public function FighterAILogic(AILevel:int , fighter:FighterMain)
		{
			super(AILevel,fighter);
		}

		public override function render():void{
			super.render();
			if(!_fighter || !_target) return;
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

		protected override function updateActionAI():void{
			updateDashAI();

			updateAttackAI();
			updateSkill();
			updateBisha();

			updateCache();

			updateAssist();
		}

		private function updateHurtAI():void{
			downJump = false;

			var downJumpObj:Object = {};
			downJumpObj['defult'] = [0,0,0.2,1,3,5];
			downJumpObj[FighterActionState.SKILL_ING] = [0,0,0,0,0,0];
			downJumpObj[FighterActionState.BISHA_ING] = downJumpObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];

			downJump = getAIByFighterState(downJumpObj);

		}

		private function updateMoveAI():void{
			moveLeft = false;
			moveRight = false;

			var isDefensing:Boolean = _fighter.actionState == FighterActionState.DEFENCE_ING;

			if(isDefensing){
				var defenseMove:Boolean = getAIResult(1,2,4,5,6,8);
				if(defenseMove){
					if(_fighter.x > _target.x + 20){
						moveLeft = true;
					}
					if(_fighter.x < _target.x - 20){
						moveRight = true;
					}
				}
				return;
			}


			var moving:Boolean;
			if(_moveFrame < GameConfig.FPS_GAME){
				_moveFrame ++;
				moving = true;
			}else{
				var moveObj:Object = {};
				moveObj['defult'] = [3,5,7,8,9,10];
				moveObj[FighterActionState.ATTACK_ING] = [2,4,5,3,1,0];
				moveObj[FighterActionState.SKILL_ING] = [2,4,3,2,0,0];
				moveObj[FighterActionState.BISHA_ING] = moveObj[FighterActionState.BISHA_SUPER_ING] = [2,1,0,0,0,0];
				moving = getAIByFighterState(moveObj);
				if(moving) _moveFrame = 0;
			}

			if(moving){

				var isCatch:Boolean = ( catch1 || catch2 ) && ( Math.abs(_fighter.y - _target.y) < 2 );

				var moveKeep:Number = isCatch ? _catchMoveKeep : _moveKeep;

				if(_fighter.x > _target.x + moveKeep){
					moveLeft = true;
				}

				if(_fighter.x < _target.x - moveKeep){
					moveRight = true;
				}

			}

			if(!moveLeft && !moveRight){
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

		private function updateJumpAI():void{
			var jumpObj:Object = {};

			if(_isConting){
				jumpObj['defult'] = [1,2,3,2,1,0];
				jumpObj[FighterActionState.HURT_ING] = [0,1,2,3,3,4];
			}else{
				if(_fighter.y > _target.y + _jumpKeep){
					jumpObj['defult'] = [2,3,4,5,6,6];
					jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = [2,1,0,0,0,0];
				}else{
					jumpObj['defult'] = [0.01,0,0,0,0,0];
					jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = [0.02,0,0,0,0,0];
				}
			}

			jump = getAIByFighterState(jumpObj);

			if(_isConting && jump){
				addContOrder('jump',10);
			}
		}

		private function updateJumpDownAI():void{
			var jumpObj:Object = {};

			if(_fighter.y < _target.y - _jumpKeep){
				jumpObj['defult'] = [2,3,4,5,6,6];
				jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = [2,1,0,0,0,0];
			}else{
				jumpObj['defult'] = [0.01,0,0,0,0,0];
				jumpObj[FighterActionState.BISHA_ING] = jumpObj[FighterActionState.BISHA_SUPER_ING] = [0.02,0,0,0,0,0];
			}

			jumpDown = getAIByFighterState(jumpObj);
		}

		private function updateDashAI():void{
			var dashObj:Object = {};

			var dis:Number = getTargetDistance(_target).x;
			var direct:Number = _target.x > _fighter.x ? 1 : -1;

			if(_fighter.energy < 40){
				if(dis > _dashKeep && _fighter.direct == direct){
					dashObj['defult'] = [0,0,0.1,0.5,0,0];
					dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] = [0,0.05,0.3,1,0,0];
					dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];
				}else{
					dashObj['defult'] = [0,0,0.05,0,0,0];
					dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] =
					dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];
				}
			}else{
				if(dis > _dashKeep && _fighter.direct != _target.direct){
					dashObj['defult'] = [0.5,1,2,5,7,9];
					dashObj[FighterActionState.ATTACK_ING] = [0,0,0.1,3,1,0];
					dashObj[FighterActionState.SKILL_ING] = [0,0,0.05,1,0,0];
					dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];
				}else{
					dashObj['defult'] = [0,0,0.05,0.1,0,0];
					dashObj[FighterActionState.ATTACK_ING] = dashObj[FighterActionState.SKILL_ING] =
					dashObj[FighterActionState.BISHA_ING] = dashObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];
				}
			}

			dash = getAIByFighterState(dashObj);
		}


		private function updateDefenseAI():void{

//			if(defense){
//				if(_defenseFrame > 0){
//					_defenseFrame--;
//					return;
//				}else{
//					_defenseFrame = GameConfig.FPS_GAME;
//				}
//			}


			if(defense){
				var ctobj:Object = {};
				ctobj['defult'] = [10,10,10,10,10,10];
				ctobj[FighterActionState.FREEZE]   = [5,4,4,3,2,1];
				ctobj[FighterActionState.NORMAL]   = [2, 1, 1, 0, 0, 0];
				ctobj[FighterActionState.HURT_ING] = [0,0,0,0,0,0];
				ctobj[FighterActionState.HURT_FLYING] = [0,0,0,0,0,0];
				ctobj[FighterActionState.HURT_DOWN] = [0,0,0,0,0,0];
				defense = getAIByFighterState(ctobj);
				if(defense) return;
			}


			var distance:Point = getTargetDistance(_target);

			var resultObj:Object = {};
			var defenseObj:Object;


			resultObj['defult'] = [0,0,0,0,0,0];
			if(distance.x < 100 && distance.y < 100){
				resultObj[FighterActionState.ATTACK_ING] = [0.5,1,3,5,7,9];
			}else{
				resultObj[FighterActionState.ATTACK_ING] = [0.5,1,3,2,1,0];
			}
			resultObj[FighterActionState.SKILL_ING] = [1,3,5,7,9,10];
			resultObj[FighterActionState.BISHA_ING] = resultObj[FighterActionState.BISHA_SUPER_ING] = [2,4,6,8,10,10];
			defense = getAIByFighterState(resultObj);

			if(defense) return;

			var targets:Vector.<IGameSprite> = _fighter.getTargets();

			for each(var i:IGameSprite in targets){
				if(i == _target){
					continue;
				}
				if(i is Bullet && (i as Bullet).isAttacking()){
					var dis:Point = getTargetDistance(i);
					if(dis.x < 200 && dis.y < 150){
						defense = getAIResult(2,4,5,7,9,10);
					}else{
						defense = getAIResult(2,4,5,5,2,1);
					}
					if(defense) return;
				}
				if(i is FighterAttacker && (i as FighterAttacker).isAttacking){
					defense = getAIResult(2,4,5,7,9,10);
					if(defense) return;
				}
				if(i is Assister && (i as Assister).isAttacking){
					defense = getAIResult(2,4,6,8,10,10);
					if(defense) return;
				}
			}

		}

		private function updateAttackAI():void{
			attack = false;
			attackAIR = false;

			if(!_fighterAction.attack && !_fighterAction.attackAIR) return;
			if(!targetCanBeHit()) return;

			var attackObj:Object = {};
			attackObj.defult = _isConting ? [1,2,3,6,9,10] : [0.5,1,4,6,8,10];
			attackObj[FighterActionState.DEFENCE_ING] = [0.5,1,3,2,2,1];
			attackObj[FighterActionState.HURT_ACT_ING] = [0.5,1,1,0.5,0,0];
			attackObj[FighterActionState.ATTACK_ING] = [0.5,1,1,0,0,0];
			attackObj[FighterActionState.SKILL_ING] =
				attackObj[FighterActionState.BISHA_ING] =
				attackObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];


			var result:Boolean = getAIByFighterState(attackObj);
			if(!result) return;

			var order:int = 10;

			if(_isConting){
				attack = true;
				attackAIR = _fighter.y < _target.y;

				var curAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();

				if(curAction == '砍1'){
					order = 200;
				}

			}else{
				attack = targetInRange(FighterHitRange.ATTACK);
				attackAIR = targetInRange(FighterHitRange.JUMP_ATTACK) && _fighter.y < _target.y;
				order = 300;
			}

			if(attack) addContOrder('attack',order);
			if(attackAIR) addContOrder('attackAIR',order);

		}

		private function updateSkill():void{

			skill1 = _fighterAction.skill1 && getSkillAI('skill1','kj1',FighterHitRange.SKILL1,10);
			skill2 = _fighterAction.skill2 && getSkillAI('skill2','kj2',FighterHitRange.SKILL2,10);

			zhao1 = _fighterAction.zhao1 && getSkillAI('zhao1','zh1',FighterHitRange.ZHAO1,10);
			zhao2 = _fighterAction.zhao2 && getSkillAI('zhao2','zh2',FighterHitRange.ZHAO2,10);
			zhao3 = _fighterAction.zhao3 && getSkillAI('zhao3','zh3',FighterHitRange.ZHAO3,10);

			skillAIR = _fighterAction.skillAIR && getSkillAI('skillAIR','tz',FighterHitRange.JUMP_SKILL,10);
		}

		private function getSkillAI(id:String , hitId:String , range:String , order:int):Boolean{
			var skillObj:Object = {};
			var result:Boolean = false;

			if(isBreakAct(hitId)){
				skillObj.defult = _isConting ? [0.1,0.2,0.5,3,6,10] : [0,0.2,0.5,2,1,0];
				skillObj[FighterActionState.DEFENCE_ING] = _isConting ? [0,0.2,0.7,5,7,9] : [0.1,0.2,0.5,1,2,2];
			}else{
				skillObj.defult = _isConting ? [0,0,0.1,1,5,10] : [0.1,0.5,1,3,2,0.2];
				skillObj[FighterActionState.DEFENCE_ING] = [0,0,1,1,0,0];
			}

			skillObj[FighterActionState.HURT_ACT_ING] = [0.5,1,0.5,0,0,0];
			skillObj[FighterActionState.ATTACK_ING] = [0,0,0,1,1,2];
			skillObj[FighterActionState.SKILL_ING] =
				skillObj[FighterActionState.BISHA_ING] =
				skillObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];

			result = getAIByFighterState(skillObj) && targetCanBeHit() && targetInRange(range);

			if(result){
				if(_isConting){
					addContOrder(id , isHitDownAct(hitId) ? order : order+100);
				}
			}

			return result;
		}

		public function updateBisha():void{
			bisha = _fighterAction.bisha && getBishaAI('bisha','bs',FighterHitRange.BISHA,100,100);
			bishaUP = _fighterAction.bishaUP && getBishaAI('bishaUP','sbs',FighterHitRange.BISHA_UP,100,100);
			bishaSUPER = _fighterAction.bishaSUPER && getBishaAI('bishaSUPER','cbs',FighterHitRange.BISHA_SUPER,300,200);
			bishaAIR = _fighterAction.bishaAIR && getBishaAI('bishaAIR','kbs',FighterHitRange.BISHA_AIR,100,210);
		}

		private function getBishaAI(id:String , hitId:String , range:String , qi:int , order:int):Boolean{
			var bishaObj:Object = {};
			var result:Boolean = false;

			if(_fighter.qi >= qi){
				if(isBreakAct(hitId)){
					bishaObj.defult = _isConting ? [0,0,0.3,2,5,10] : [0.1,0.2,0.5,2,2,2];
					bishaObj[FighterActionState.DEFENCE_ING] = _isConting ? [0,0,0.5,3,7,9] : [0.1,0.2,1,6,8,10];
				}else{
					bishaObj.defult = _isConting ? [0,0,0.5,4,8,10] : [0.2,0.5,1,2,2,0];
					bishaObj[FighterActionState.HURT_ING] = [0.2,0.5,1,3,5,6];
					bishaObj[FighterActionState.JUMP_ING] = [0.2,0.5,1,3,4,4];
					bishaObj[FighterActionState.DEFENCE_ING] = _isConting ? [0.2,0.5,1,3,2,1] : [0.2,0.5,1,2,1,0];
				}

				bishaObj[FighterActionState.HURT_ACT_ING] = [0.2,0.5,0,0,0,0];
				bishaObj[FighterActionState.ATTACK_ING] = [0,0.2,0.5,2,1,1];
				bishaObj[FighterActionState.SKILL_ING] =
					bishaObj[FighterActionState.BISHA_ING] =
					bishaObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0.1,0,0,0];

				result = getAIByFighterState(bishaObj) && targetCanBeHit() && targetInRange(range);
			}

			if(result){
				if(_isConting){
					addContOrder(id , order);
				}
			}

			return result;
		}

		private function updateCache():void{
			catch1 = false;
			catch2 = false;


			var cacheObj:Object = {};
			if(_targetFighter && (
				_targetFighter.actionState == FighterActionState.HURT_ING ||
				_targetFighter.actionState == FighterActionState.HURT_FLYING ||
				_targetFighter.actionState == FighterActionState.HURT_DOWN
			)) return;

			var dis:Point = getTargetDistance(_target);
			if(dis.x < 50){
				cacheObj.defult = [0,0.5,1,3,2,1];
				cacheObj[FighterActionState.DEFENCE_ING] = [1,2,4,5,7,10];
			}else{
				cacheObj.defult = [0,0.5,1,0,0,0];
				cacheObj[FighterActionState.DEFENCE_ING] = [1,2,3,4,3,2];
			}

			catch1 = getAIByFighterState(cacheObj) && targetCanBeHit();
			catch2 = getAIByFighterState(cacheObj) && targetCanBeHit();

			if(catch1){
				addContOrder('catch1',150);
			}
			if(catch2){
				addContOrder('catch2',110);
			}

		}


		private function updateSpecialSkill():void{

			if(_fighter.actionState == FighterActionState.HURT_ING){

				if(_fighter.hp > _fighter.hpMax * 0.6) return;
				if(_fighter.qi < 150) return;

				//被打反击
				var breakObj:Object = {};
				breakObj.defult = [0,0,0,0,0.1,0.2];
				breakObj[FighterActionState.SKILL_ING] = [0,0,0,0,0.2,0.4];
				specialSkill = getAIByFighterState(breakObj);
			}
		}

		private function updateAssist():void{
			//招唤
			var callObj:Object = {};
			callObj.defult = [0,0.02,0.05,0.05,0,0];
			callObj[FighterActionState.DEFENCE_ING] = [0,0.02,0.05,0.1,0.3,0.5];
//			callObj[FighterActionState.ATTACK_ING] = [0,0,0,1,2,2];
//			callObj[FighterActionState.SKILL_ING] = [0,0,0,1,1,1];
			callObj[FighterActionState.BISHA_ING] = [0,0,0,0,0,0];
			callObj[FighterActionState.BISHA_SUPER_ING] = [0,0,0,0,0,0];
			assist = getAIByFighterState(callObj);
		}

		private function updateGhostStep():void{

			var dis:Point = getTargetDistance(_target);

			if(dis.x > 80 || dis.y > 80) return;
			if(_fighter.qi < 200) return;

			if(_fighter.actionState != FighterActionState.ATTACK_ING && _fighter.actionState != FighterActionState.SKILL_ING) return;

			var ghostStepObj:Object = {};
			ghostStepObj.defult = [0,0,0,0,0,0];
			ghostStepObj[FighterActionState.HURT_ING] = [0,0,0,0,0.1,0.2];

			ghostStep = getAIByFighterState(ghostStepObj);

			if(_target.y - _fighter.y < -80 && _target.y - _fighter.y > -100){
				var ghostJumpObj:Object = {};
				ghostJumpObj.defult = [0,0,0,0,0,0];
				ghostJumpObj[FighterActionState.HURT_ING] = [0,0,0.1,0.1,0.1,0.1];
				ghostJump = getAIByFighterState(ghostStepObj);
			}else{
				ghostJump = false;
			}

			if(_target.y - _fighter.y < 80 && _target.y - _fighter.y > 100){
				var ghostDwonObj:Object = {};
				ghostDwonObj.defult = [0,0,0,0,0,0];
				ghostDwonObj[FighterActionState.HURT_ING] = [0,0,0,0.1,0.1,0.1];
				ghostJumpDowm = getAIByFighterState(ghostDwonObj);
			}else{
				ghostJumpDowm = false;
			}

		}

	}
}
