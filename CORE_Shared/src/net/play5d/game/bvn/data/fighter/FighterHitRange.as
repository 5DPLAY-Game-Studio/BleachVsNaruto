/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.fighter {

/**
 * 角色攻击范围元件名
 */
public class FighterHitRange {
    include '../../../../../../../include/ImportVersion.as';

    // 跳砍 KJ
    public static const ATTACK_AIR:String = 'tkanmian';
    // 跳招 KU
    public static const SKILL_AIR:String  = 'tzmian';

    // 砍1 J
    public static const ATTACK:String = 'kanmian';

    // 砍技1 SJ
    public static const SKILL_1:String = 'kj1mian';
    // 砍技2 WJ
    public static const SKILL_2:String = 'kj2mian';

    // 招1 U
    public static const ZHAO_1:String = 'zh1mian';
    // 招2 SU
    public static const ZHAO_2:String = 'zh2mian';
    // 招3 WU
    public static const ZHAO_3:String = 'zh3mian';

    // 必杀 I
    public static const BISHA:String       = 'bsmian';
    // 空中必杀 KI
    public static const BISHA_AIR:String   = 'kbsmian';
    // 上必杀 WI
    public static const BISHA_UP:String    = 'sbsmian';
    // 超必杀 SI
    public static const BISHA_SUPER:String = 'cbsmian';

    // 全部攻击范围元件名
    public static const ALL_HIT_RANGES:Vector.<String> = (function ():Vector.<String> {
        var allHitRanges:Vector.<String> = new Vector.<String>();
        allHitRanges.push(
                ATTACK_AIR, SKILL_AIR,
                ATTACK,
                SKILL_1, SKILL_2,
                ZHAO_1, ZHAO_2, ZHAO_3,
                BISHA, BISHA_AIR, BISHA_UP, BISHA_SUPER
        );

        return allHitRanges;
    })();
}
}
