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
 * 角色攻击范围元件名公开常量。
 *
 * <p>对应角色 SWF 攻击判定面链接名，供命中检测按招式取范围。</p>
 *
 * @see FighterSpecialFrame
 */
public class FighterHitRange {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 跳砍（KJ）。
     *
     * @default tkanmian
     */
    public static const ATTACK_AIR:String = 'tkanmian';
    /**
     * 跳招（KU）。
     *
     * @default tzmian
     */
    public static const SKILL_AIR:String  = 'tzmian';

    /**
     * 砍 1（J）。
     *
     * @default kanmian
     */
    public static const ATTACK:String = 'kanmian';

    /**
     * 砍技 1（SJ）。
     *
     * @default kj1mian
     */
    public static const SKILL_1:String = 'kj1mian';
    /**
     * 砍技 2（WJ）。
     *
     * @default kj2mian
     */
    public static const SKILL_2:String = 'kj2mian';

    /**
     * 招 1（U）。
     *
     * @default zh1mian
     */
    public static const ZHAO_1:String = 'zh1mian';
    /**
     * 招 2（SU）。
     *
     * @default zh2mian
     */
    public static const ZHAO_2:String = 'zh2mian';
    /**
     * 招 3（WU）。
     *
     * @default zh3mian
     */
    public static const ZHAO_3:String = 'zh3mian';

    /**
     * 必杀（I）。
     *
     * @default bsmian
     */
    public static const BISHA:String       = 'bsmian';
    /**
     * 空中必杀（KI）。
     *
     * @default kbsmian
     */
    public static const BISHA_AIR:String   = 'kbsmian';
    /**
     * 上必杀（WI）。
     *
     * @default sbsmian
     */
    public static const BISHA_UP:String    = 'sbsmian';
    /**
     * 超必杀（SI）。
     *
     * @default cbsmian
     */
    public static const BISHA_SUPER:String = 'cbsmian';

    /**
     * 全部攻击范围元件名（本类各常量的集合，便于遍历注册判定面）。
     *
     * @default ATTACK_AIR, SKILL_AIR, ATTACK, SKILL_1, SKILL_2, ZHAO_1, ZHAO_2, ZHAO_3, BISHA, BISHA_AIR, BISHA_UP, BISHA_SUPER
     */
    public static const ALL_HIT_RANGES:Vector.<String> = new <String>[
        ATTACK_AIR, SKILL_AIR,
        ATTACK,
        SKILL_1, SKILL_2,
        ZHAO_1, ZHAO_2, ZHAO_3,
        BISHA, BISHA_AIR, BISHA_UP, BISHA_SUPER
    ];
}
}
