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

package net.play5d.game.bvn.fighter.data {
public class FighterHitRange {
    include '../../../../../../../include/_INCLUDE_.as';

    public static const JUMP_ATTACK:String = 'tkanmian';
    public static const JUMP_SKILL:String  = 'tzmian';

    public static const ATTACK:String = 'kanmian';

    public static const SKILL1:String = 'kj1mian';
    public static const SKILL2:String = 'kj2mian';

    public static const ZHAO1:String = 'zh1mian';
    public static const ZHAO2:String = 'zh2mian';
    public static const ZHAO3:String = 'zh3mian';

    public static const BISHA:String       = 'bsmian';
    public static const BISHA_AIR:String   = 'kbsmian';
    public static const BISHA_UP:String    = 'sbsmian';
    public static const BISHA_SUPER:String = 'cbsmian';

    public static function getALL():Array {
        return [
            JUMP_ATTACK, JUMP_SKILL, ATTACK, SKILL1, SKILL2, ZHAO1, ZHAO2, ZHAO3,
            BISHA, BISHA_AIR, BISHA_UP, BISHA_SUPER
        ];
    }

    public function FighterHitRange() {
    }
}
}
