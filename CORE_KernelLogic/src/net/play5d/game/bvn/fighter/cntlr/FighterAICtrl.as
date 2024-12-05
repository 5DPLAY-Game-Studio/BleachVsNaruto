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

package net.play5d.game.bvn.fighter.cntlr {

import net.play5d.game.bvn.cntlr.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.cntlr.ai.FighterAILogic;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterAICtrl implements IFighterActionCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterAICtrl() {
    }
    public var AILevel:int; //1-6  very easy,easy,normal,hrad,very hard,hell
    public var fighter:FighterMain;
//		private var _targetFighter:FighterMain;
    private var _target:IGameSprite;
    private var _ai_update_gap:int;
    private var _ai_update_frame:int;
    private var _AIlogic:FighterAILogic;

    public function initlize():void {
//			_fighter.addEventListener(FighterEvent.DO_ACTION,onFighterDoAction);
//			AILevel = level;

        _AIlogic = new FighterAILogic(AILevel, fighter);

//			switch(AILevel){
//				case 0:
//				case 1: //very easy
//					_ai_update_gap = 1 * GameConfig.FPS_GAME;
//					break;
//				case 2: //easy
//					_ai_update_gap = 0.5 * GameConfig.FPS_GAME;
//					break;
//				case 3: //normal
//					_ai_update_gap = 0.3 * GameConfig.FPS_GAME;
//					break;
//				case 4: //hard
//					_ai_update_gap = 0.1 * GameConfig.FPS_GAME;
//					break;
//				case 5: //very hard
//					_ai_update_gap = 0.05 * GameConfig.FPS_GAME;
//					break;
//				case 6: //hell
//					_ai_update_gap = 1;
//					break;
//			}
//
//			if(_ai_update_gap < 1) _ai_update_gap = 1;

    }

    public function destory():void {
        fighter = null;
        _target = null;
        if (_AIlogic) {
            _AIlogic.destory();
            _AIlogic = null;
        }
//			_fighter.removeEventListener(FighterEvent.DO_ACTION,onFighterDoAction);
    }

//		private function onFighterDoAction(e:FighterEvent):void{
//			_AIlogic.onDoAction();
//		}

    public function enabled():Boolean {
        return GameCtrl.I.actionEnable;
    }

    public function render():void {
//			_ai_update_frame++;
//			_AIlogic.render();
//			if(_ai_update_frame > _ai_update_gap){
//				_target = _fighter.getCurrentTarget();
////				_targetFighter = _target as FighterMain;
//				_AIlogic.updateAI(_target);
//				_ai_update_frame = 0;
//			}
    }

    public function renderAnimate():void {
        _AIlogic.render();
    }

    public function moveLEFT():Boolean {
        return _AIlogic.moveLeft;
    }

    public function moveRIGHT():Boolean {
        return _AIlogic.moveRight;
    }

    public function defense():Boolean {
        return _AIlogic.defense;
    }

    public function attack():Boolean {
        return _AIlogic.attack;
    }

    public function jump():Boolean {
        return _AIlogic.jump;
    }

    public function jumpQuick():Boolean {
        return false;
    }

    public function jumpDown():Boolean {
        return _AIlogic.jumpDown;
    }

    public function dash():Boolean {
        return _AIlogic.dash;
    }

    public function dashJump():Boolean {
        return _AIlogic.downJump;
    }

    public function skill1():Boolean {
        return _AIlogic.skill1;
    }

    public function skill2():Boolean {
        return _AIlogic.skill2;
    }

    public function zhao1():Boolean {
        return _AIlogic.zhao1;
    }

    public function zhao2():Boolean {
        return _AIlogic.zhao2;
    }

    public function zhao3():Boolean {
        return _AIlogic.zhao3;
    }

    public function catch1():Boolean {
        return _AIlogic.catch1;
    }

    public function catch2():Boolean {
        return _AIlogic.catch2;
    }

    public function bisha():Boolean {
        return _AIlogic.bisha;
    }

    public function bishaUP():Boolean {
        return _AIlogic.bishaUP;
    }

    public function bishaSUPER():Boolean {
        return _AIlogic.bishaSUPER;
    }

    public function assist():Boolean {
        return _AIlogic.assist;
    }

    public function specailSkill():Boolean {
        return _AIlogic.specialSkill;
    }

    public function attackAIR():Boolean {
        return _AIlogic.attackAIR;
    }

    public function skillAIR():Boolean {
        return _AIlogic.skillAIR;
    }

    public function bishaAIR():Boolean {
        return _AIlogic.bishaAIR;
    }

    public function waiKai():Boolean {
        return false;
    }

    public function waiKaiW():Boolean {
        return false;
    }

    public function waiKaiS():Boolean {
        return false;
    }

    public function ghostStep():Boolean {
        return _AIlogic.ghostStep;
    }

    public function ghostJump():Boolean {
        return _AIlogic.ghostJump;
    }

    public function ghostJumpDown():Boolean {
        return _AIlogic.ghostJumpDowm;
    }
}
}
