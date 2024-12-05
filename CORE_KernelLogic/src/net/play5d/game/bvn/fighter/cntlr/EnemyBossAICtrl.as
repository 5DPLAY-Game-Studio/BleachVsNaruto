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
public class EnemyBossAICtrl extends FighterAICtrl {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public function EnemyBossAICtrl() {
        super();
    }

    public override function waiKai():Boolean {
        return false;
    }

    public override function waiKaiW():Boolean {
        return false;
    }

    public override function waiKaiS():Boolean {
        return false;
    }

    public override function ghostStep():Boolean {
        return false;
    }

    public override function ghostJump():Boolean {
        return false;
    }

    public override function ghostJumpDown():Boolean {
        return false;
    }

    public override function assist():Boolean {
        return false;
    }

    public override function specailSkill():Boolean {
        return false;
    }

    public override function bishaSUPER():Boolean {
        return false;
    }

    public override function catch1():Boolean {
        return false;
    }

    public override function catch2():Boolean {
        return false;
    }

}
}
