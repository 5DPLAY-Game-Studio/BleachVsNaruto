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

import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.ai.FighterAILogic;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class FighterAICtrl implements IFighterActionCtrl {

    public var AILevel:int; //1-6  very easy,easy,normal,hrad,very hard,hell
    public var fighter:FighterMain;
    private var _target:IGameSprite;
    private var _ai_update_gap:int;
    private var _ai_update_frame:int;
    private var _AIlogic:FighterAILogic;

    public function initialize():void {

        _AIlogic = new FighterAILogic(AILevel, fighter);

    }

    public function destroy():void {
        fighter = null;
        _target = null;
        if (_AIlogic) {
            _AIlogic.destroy();
            _AIlogic = null;
        }
    }

    public function enabled():Boolean {
        return GameCtrl.I.actionEnable;
    }

    public function render():void {
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
