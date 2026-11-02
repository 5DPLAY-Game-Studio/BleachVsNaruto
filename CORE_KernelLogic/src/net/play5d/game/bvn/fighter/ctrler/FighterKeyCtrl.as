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
import net.play5d.game.bvn.input.GameInputter;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;

public class FighterKeyCtrl implements IFighterActionCtrl {

    public var inputType:String;
    public var classicMode:Boolean = false;
    private var _justDown:int      = 0;

    public function initialize():void {
        if (!classicMode) {
            _justDown = 2;
            GameInputter.listenKeys(inputType, ['attack', 'jump', 'dash', 'skill', 'superSkill'], 2);
        }
        else {
            _justDown = 0;
        }
    }

    public function render():void {

    }

    public function renderAnimate():void {

    }

    public function destroy():void {
        if (!classicMode) {
            GameInputter.unListenKeys(inputType, 2);
        }
    }

    public function enabled():Boolean {
        return GameCtrl.I.actionEnable;
    }

    public function moveLEFT():Boolean {
        return GameInputter.left(inputType, 0) && !GameInputter.right(inputType, 0);
    }

    public function moveRIGHT():Boolean {
        return GameInputter.right(inputType, 0) && !GameInputter.left(inputType, 0);
    }

    public function defense():Boolean {
        return GameInputter.down(inputType, 0);
    }

    public function attack():Boolean {
        return GameInputter.attack(inputType, _justDown) &&
               !(
                       GameInputter.up(inputType, 0) || GameInputter.down(inputType, 0) || GameInputter.jump(inputType, 0)
               );
    }

    public function jump():Boolean {
        return GameInputter.jump(inputType, _justDown) && !GameInputter.attack(inputType, 0);
    }

    public function jumpQuick():Boolean {
        if (classicMode) {
            return false;
        }
        return GameInputter.jump(inputType, _justDown) && !GameInputter.attack(inputType, 0);
    }

    public function jumpDown():Boolean {
        return GameInputter.down(inputType, 0) && GameInputter.jump(inputType, _justDown);
    }

    public function dash():Boolean {
        return GameInputter.dash(inputType, _justDown) &&
               !(
                       GameInputter.up(inputType, 0) , GameInputter.down(inputType, 0)
               );
    }

    public function dashJump():Boolean {
        return GameInputter.dash(inputType, _justDown);
    }

    public function skill1():Boolean {
        return GameInputter.down(inputType, 0) && GameInputter.attack(inputType, _justDown);
    }

    public function skill2():Boolean {
        return GameInputter.up(inputType, 0) && GameInputter.attack(inputType, _justDown);
    }

    public function zhao1():Boolean {
        return GameInputter.skill(inputType, _justDown) && !GameInputter.up(inputType, 0) &&
               !GameInputter.down(inputType, 0);
    }

    public function zhao2():Boolean {
        return GameInputter.down(inputType, 0) && GameInputter.skill(inputType, _justDown);
    }

    public function zhao3():Boolean {
        return GameInputter.up(inputType, 0) && GameInputter.skill(inputType, _justDown);
    }

    public function catch1():Boolean {
        return GameInputter.attack(inputType, 2) && (
                GameInputter.left(inputType, 0) || GameInputter.right(inputType, 0)
        );
    }

    public function catch2():Boolean {
        return GameInputter.skill(inputType, 2) && (
                GameInputter.left(inputType, 0) || GameInputter.right(inputType, 0)
        );
    }

    public function bisha():Boolean {
        return GameInputter.superSkill(inputType, _justDown) &&
               !(
                       GameInputter.up(inputType, 0) || GameInputter.down(inputType, 0)
               );
    }

    public function bishaUP():Boolean {
        return GameInputter.superSkill(inputType, _justDown) && GameInputter.up(inputType, 0);
    }

    public function bishaSUPER():Boolean {
        return GameInputter.superSkill(inputType, _justDown) && GameInputter.down(inputType, 0);
    }

    public function assist():Boolean {
        return GameInputter.special(inputType, 0);
    }

    public function specialSkill():Boolean {
        return GameInputter.special(inputType, 0);
    }

    public function attackAIR():Boolean {
        return GameInputter.attack(inputType, _justDown);
    }

    public function skillAIR():Boolean {
        return GameInputter.skill(inputType, _justDown);
    }

    public function bishaAIR():Boolean {
        return GameInputter.superSkill(inputType, _justDown);
    }

    public function waiKai():Boolean {
        return GameInputter.wankai(inputType, 0) && !(
                GameInputter.up(inputType, 0) || GameInputter.down(inputType, 0)
        );
    }

    public function waiKaiW():Boolean {
        return GameInputter.up(inputType, 0) && GameInputter.wankai(inputType, 0);
    }

    public function waiKaiS():Boolean {
        return GameInputter.down(inputType, 0) && GameInputter.wankai(inputType, 0);
    }

    public function ghostStep():Boolean {
        return GameInputter.dash(inputType, _justDown) && GameInputter.down(inputType, 0);
    }

    public function ghostJump():Boolean {
        return GameInputter.dash(inputType, _justDown) && GameInputter.up(inputType, 0);
    }

    public function ghostJumpDown():Boolean {
        return GameInputter.dash(inputType, _justDown) && GameInputter.down(inputType, 0);
    }

}
}
