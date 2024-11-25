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

package net.play5d.game.bvn.fighter {
public class FighterActionState {
    include '../../../../../../include/_INCLUDE_.as';

    public static const NORMAL:int = 0;

    public static const FREEZE:int = 40; //硬直

    public static const ATTACK_ING:int      = 10;
    public static const SKILL_ING:int       = 11;
    public static const BISHA_ING:int       = 12;
    public static const BISHA_SUPER_ING:int = 13;
    public static const JUMP_ING:int        = 14;
    public static const DASH_ING:int        = 15;
    public static const HURT_ACT_ING:int    = 16; //被打时反击

    public static const DEFENCE_ING:int   = 20;
    public static const HURT_ING:int      = 21;
    public static const HURT_FLYING:int   = 22;
    public static const HURT_DOWN:int     = 23;
    public static const HURT_DOWN_TAN:int = 24; //弹起

    public static const DEAD:int = 30;

    public static const WAN_KAI_ING:int = 50;

    public static const KAI_CHANG:int = 60; //开场
    public static const WIN:int       = 61; //开场
    public static const LOSE:int      = 62; //失败

    public static function isAllowWinState(v:int):Boolean {
        return v != BISHA_ING && v != BISHA_SUPER_ING && v != WAN_KAI_ING;
    }

    public static function isBishaIng(v:int):Boolean {
        return [BISHA_ING, BISHA_SUPER_ING].indexOf(v) != -1;
    }

    public static function isAttacking(v:int):Boolean {
        return [ATTACK_ING, SKILL_ING, BISHA_ING, BISHA_SUPER_ING].indexOf(v) != -1;
    }

    public static function allowGhostStep(v:int):Boolean {
        return v != BISHA_ING && v != BISHA_SUPER_ING && v != WAN_KAI_ING;
    }

    public static function isHurting(v:int):Boolean {
        return [HURT_ING, HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN].indexOf(v) != -1;
    }

    public function FighterActionState() {
    }

}
}
