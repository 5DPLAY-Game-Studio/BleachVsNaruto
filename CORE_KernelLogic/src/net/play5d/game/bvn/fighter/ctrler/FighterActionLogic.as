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

package net.play5d.game.bvn.fighter.ctrler
{
	import net.play5d.game.bvn.data.mosou.MosouFighterLogic;
	import net.play5d.game.bvn.fighter.FighterAction;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IFighterActionCtrl;

	public class FighterActionLogic
	{
		include "_INCLUDE_.as";

		private var _fighter:FighterMain;
		private var _action:FighterAction;
		private var _actionCtrler:IFighterActionCtrl;
		private var _mosouLogic:MosouFighterLogic;

		public function FighterActionLogic(fighter:FighterMain)
		{
			_fighter = fighter;
		}

		public function enabled():Boolean{

			try{
				if(!_action) _action = _fighter.getCtrler().getMcCtrl().getAction();
				if(!_actionCtrler) _actionCtrler = _fighter.getCtrler().getMcCtrl().getActionCtrler();
				if(!_mosouLogic) _mosouLogic = _fighter.getMosouLogic();
			}catch(e:Error){
				trace('FighterActionLogic.enabled', e);
				return false;
			}

			return _action && _actionCtrler && _actionCtrler.enabled();
		}

		public function moveLEFT():Boolean{
			return _action.moveLeft && _actionCtrler.moveLEFT();
		}

		public function moveRIGHT():Boolean{
			return _action.moveRight && _actionCtrler.moveRIGHT();
		}

		public function airMove():Boolean{
			return _action.airMove;
		}

		public function jump():Boolean{
			return _action.jump && _actionCtrler.jump();
		}

		public function jumpQuick():Boolean{
			return _action.jumpQuick && _actionCtrler.jumpQuick();
		}

		public function jumpDown():Boolean{
			return _action.jumpDown && _actionCtrler.jumpDown();
		}

		public function attack():Boolean{
			return _action.attack && _actionCtrler.attack();
		}

		public function attackAIR():Boolean{
			return _action.attackAIR && _actionCtrler.attackAIR();
		}

		public function defense():Boolean{
			return _action.defense && _actionCtrler.defense();
		}

		public function dash():Boolean{
			return _action.dash && _actionCtrler.dash();
		}

		public function hurtFlyResume():Boolean{
			return _actionCtrler.dashJump();
		}

		public function dashJump():Boolean{
			return _actionCtrler.dashJump();
		}

		public function skill1():Boolean{
			if(_mosouLogic && !_mosouLogic.canSkill1()) return false;
			return _action.skill1 && _actionCtrler.skill1();
		}

		public function skill2():Boolean{
			if(_mosouLogic && !_mosouLogic.canSkill2()) return false;
			return _action.skill2 && _actionCtrler.skill2();
		}

		public function skillAIR():Boolean{
			if(_mosouLogic && !_mosouLogic.canSkillAir()) return false;
			return _action.skillAIR && _actionCtrler.skillAIR();
		}

		public function zhao1():Boolean{
			if(_mosouLogic && !_mosouLogic.canZhao1()) return false;
			return _action.zhao1 && _actionCtrler.zhao1();
		}

		public function zhao2():Boolean{
			if(_mosouLogic && !_mosouLogic.canZhao2()) return false;
			return _action.zhao2 && _actionCtrler.zhao2();
		}

		public function zhao3():Boolean{
			if(_mosouLogic && !_mosouLogic.canZhao3()) return false;
			return _action.zhao3 && _actionCtrler.zhao3();
		}

		public function catch1():Boolean{
			if(_mosouLogic && !_mosouLogic.canCatch1()) return false;
			return _action.catch1 && _actionCtrler.catch1();
		}

		public function catch2():Boolean{
			if(_mosouLogic && !_mosouLogic.canCatch2()) return false;
			return _action.catch2 && _actionCtrler.catch2();
		}


		public function bisha():Boolean{
			if(_mosouLogic && !_mosouLogic.canBisha()) return false;
			return _action.bisha && _actionCtrler.bisha();
		}

		public function bishaUP():Boolean{
			if(_mosouLogic && !_mosouLogic.canBishaUP()) return false;
			return _action.bishaUP && _actionCtrler.bishaUP();
		}

		public function bishaSUPER():Boolean{
			if(_mosouLogic && !_mosouLogic.canBishaSuper()) return false;
			return _action.bishaSUPER && _actionCtrler.bishaSUPER();
		}

		public function bishaAIR():Boolean{
			if(_mosouLogic && !_mosouLogic.canBishaAir()) return false;
			return _action.bishaAIR && _actionCtrler.bishaAIR();
		}

		public function ghostStep():Boolean{
			if(!FighterActionState.allowGhostStep(_fighter.actionState)) return false;
			if(_mosouLogic && !_mosouLogic.canGhostStep()) return false;
			return _actionCtrler.ghostStep();
		}

		public function ghostJump():Boolean{
			if(!FighterActionState.allowGhostStep(_fighter.actionState)) return false;
			if(_mosouLogic && !_mosouLogic.canGhostStep()) return false;
			return _actionCtrler.ghostJump();
		}

		public function ghostJumpDown():Boolean{
			if(!FighterActionState.allowGhostStep(_fighter.actionState)) return false;
			if(_mosouLogic && !_mosouLogic.canGhostStep()) return false;
			return _actionCtrler.ghostJumpDown();
		}

		public function waiKai():Boolean{
			if(_mosouLogic && !_mosouLogic.canBankai()) return false;
			return _actionCtrler.waiKai();
		}

		public function waiKaiW():Boolean{
			if(_mosouLogic && !_mosouLogic.canBankai()) return false;
			return _actionCtrler.waiKaiW();
		}

		public function waiKaiS():Boolean{
			if(_mosouLogic && !_mosouLogic.canBankai()) return false;
			return _actionCtrler.waiKaiS();
		}

		public function specailSkill():Boolean{
			return _actionCtrler.specailSkill();
		}

	}
}
