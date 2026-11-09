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
 * 角色出招指令串（练习输入历史等显示用）。
 *
 * <p>与 <code>FighterSpecialFrame</code> 注释中的按键记号一致；自定义帧标签仍按槽位记对应指令。</p>
 *
 * @see FighterSpecialFrame
 */
public class FighterInputCmd {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 左移（A）。
     *
     * @default A
     */
    public static const LEFT:String    = 'A';
    /**
     * 右移（D）。
     *
     * @default D
     */
    public static const RIGHT:String   = 'D';
    /**
     * 防御（S）。
     *
     * @default S
     */
    public static const DEFENSE:String = 'S';

    /**
     * 普通攻击（J）。
     *
     * @default J
     */
    public static const ATTACK:String  = 'J';
    /**
     * 砍技 1（SJ）。
     *
     * @default SJ
     */
    public static const SKILL_1:String = 'SJ';
    /**
     * 砍技 2（WJ）。
     *
     * @default WJ
     */
    public static const SKILL_2:String = 'WJ';

    /**
     * 招 1（U）。
     *
     * @default U
     */
    public static const ZHAO_1:String = 'U';
    /**
     * 招 2（SU）。
     *
     * @default SU
     */
    public static const ZHAO_2:String = 'SU';
    /**
     * 招 3（WU）。
     *
     * @default WU
     */
    public static const ZHAO_3:String = 'WU';

    /**
     * 必杀（I）。
     *
     * @default I
     */
    public static const BISHA:String       = 'I';
    /**
     * 上必杀（WI）。
     *
     * @default WI
     */
    public static const BISHA_UP:String    = 'WI';
    /**
     * 超必杀（SI）。
     *
     * @default SI
     */
    public static const BISHA_SUPER:String = 'SI';
    /**
     * 空中必杀（KI）。
     *
     * @default KI
     */
    public static const BISHA_AIR:String   = 'KI';

    /**
     * 跳砍（KJ）。
     *
     * @default KJ
     */
    public static const ATTACK_AIR:String  = 'KJ';
    /**
     * 跳招（KU）。
     *
     * @default KU
     */
    public static const SKILL_AIR:String   = 'KU';
    /**
     * 跳招-上（WKU）。
     *
     * @default WKU
     */
    public static const SKILL_AIR_W:String = 'WKU';
    /**
     * 跳招-下（SKU）。
     *
     * @default SKU
     */
    public static const SKILL_AIR_S:String = 'SKU';

    /**
     * 瞬步 / 起身（L）。
     *
     * @default L
     */
    public static const DASH:String      = 'L';
    /**
     * 跳（K）。
     *
     * @default K
     */
    public static const JUMP:String      = 'K';
    /**
     * 落（SK）。
     *
     * @default SK
     */
    public static const JUMP_DOWN:String = 'SK';

    /**
     * 万解（JK）。
     *
     * @default JK
     */
    public static const BANKAI:String   = 'JK';
    /**
     * 万解 W（WJK）。
     *
     * @default WJK
     */
    public static const BANKAI_W:String = 'WJK';
    /**
     * 万解 S（SJK）。
     *
     * @default SJK
     */
    public static const BANKAI_S:String = 'SJK';

    /**
     * 幽步下（SL）。
     *
     * @default SL
     */
    public static const GHOST_DASH_S:String = 'SL';
    /**
     * 幽步上（WL）。
     *
     * @default WL
     */
    public static const GHOST_DASH_W:String = 'WL';

    /**
     * 援助 / 灵压爆发 / 替身术（O）。
     *
     * @default O
     */
    public static const ASSIST:String = 'O';
}
}
