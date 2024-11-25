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
import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;

public class FighterKeyCtrl implements IFighterActionCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function FighterKeyCtrl() {
    }
    public var inputType:String;
    public var classicMode:Boolean = false;
    private var _justDown:int      = 0;

    public function initlize():void {
        if (!classicMode) {
            _justDown = 2;
            GameInputer.listenKeys(inputType, ['attack', 'jump', 'dash', 'skill', 'superSkill'], 2);
        }
        else {
            _justDown = 0;
        }
    }

    public function render():void {

    }

    public function renderAnimate():void {

    }

    public function destory():void {
        if (!classicMode) {
            GameInputer.unListenKeys(inputType, 2);
        }
    }

    public function enabled():Boolean {
        return GameCtrl.I.actionEnable;
    }

    public function moveLEFT():Boolean {
        return GameInputer.left(inputType, 0) && !GameInputer.right(inputType, 0);
    }

    public function moveRIGHT():Boolean {
        return GameInputer.right(inputType, 0) && !GameInputer.left(inputType, 0);
    }

    public function defense():Boolean {
        return GameInputer.down(inputType, 0);
    }

    public function attack():Boolean {
        return GameInputer.attack(inputType, _justDown) &&
               !(
                       GameInputer.up(inputType, 0) || GameInputer.down(inputType, 0) || GameInputer.jump(inputType, 0)
               );
    }

    public function jump():Boolean {
        return GameInputer.jump(inputType, _justDown) && !GameInputer.attack(inputType, 0);
    }

    public function jumpQuick():Boolean {
        if (classicMode) {
            return false;
        }
        return GameInputer.jump(inputType, _justDown) && !GameInputer.attack(inputType, 0);
    }

    public function jumpDown():Boolean {
        return GameInputer.down(inputType, 0) && GameInputer.jump(inputType, _justDown);
    }

    public function dash():Boolean {
        return GameInputer.dash(inputType, _justDown) &&
               !(
                       GameInputer.up(inputType, 0) , GameInputer.down(inputType, 0)
               );
    }

    public function dashJump():Boolean {
        return GameInputer.dash(inputType, _justDown);
    }

    public function skill1():Boolean {
        return GameInputer.down(inputType, 0) && GameInputer.attack(inputType, _justDown);
    }

    public function skill2():Boolean {
        return GameInputer.up(inputType, 0) && GameInputer.attack(inputType, _justDown);
    }

    public function zhao1():Boolean {
        return GameInputer.skill(inputType, _justDown) && !GameInputer.up(inputType, 0) &&
               !GameInputer.down(inputType, 0);
    }

    public function zhao2():Boolean {
        return GameInputer.down(inputType, 0) && GameInputer.skill(inputType, _justDown);
    }

    public function zhao3():Boolean {
        return GameInputer.up(inputType, 0) && GameInputer.skill(inputType, _justDown);
    }

    public function catch1():Boolean {
        return GameInputer.attack(inputType, 2) && (
                GameInputer.left(inputType, 0) || GameInputer.right(inputType, 0)
        );
    }

    public function catch2():Boolean {
        return GameInputer.skill(inputType, 2) && (
                GameInputer.left(inputType, 0) || GameInputer.right(inputType, 0)
        );
    }

    public function bisha():Boolean {
        return GameInputer.superSkill(inputType, _justDown) &&
               !(
                       GameInputer.up(inputType, 0) || GameInputer.down(inputType, 0)
               );
    }

    public function bishaUP():Boolean {
        return GameInputer.superSkill(inputType, _justDown) && GameInputer.up(inputType, 0);
    }

    public function bishaSUPER():Boolean {
        return GameInputer.superSkill(inputType, _justDown) && GameInputer.down(inputType, 0);
    }

    public function assist():Boolean {
        return GameInputer.special(inputType, 0);
    }

    public function specailSkill():Boolean {
        return GameInputer.special(inputType, 0);
    }

    public function attackAIR():Boolean {
        return GameInputer.attack(inputType, _justDown);
    }

    public function skillAIR():Boolean {
        return GameInputer.skill(inputType, _justDown);
    }

    public function bishaAIR():Boolean {
        return GameInputer.superSkill(inputType, _justDown);
    }

    public function waiKai():Boolean {
        return GameInputer.wankai(inputType, 0) && !(
                GameInputer.up(inputType, 0) || GameInputer.down(inputType, 0)
        );
    }

    public function waiKaiW():Boolean {
        return GameInputer.up(inputType, 0) && GameInputer.wankai(inputType, 0);
    }

    public function waiKaiS():Boolean {
        return GameInputer.down(inputType, 0) && GameInputer.wankai(inputType, 0);
    }

    public function ghostStep():Boolean {
        return GameInputer.dash(inputType, _justDown) && GameInputer.down(inputType, 0);
    }

    public function ghostJump():Boolean {
        return GameInputer.dash(inputType, _justDown) && GameInputer.up(inputType, 0);
    }

    public function ghostJumpDown():Boolean {
        return GameInputer.dash(inputType, _justDown) && GameInputer.down(inputType, 0);
    }

}
}
