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
 * 角色特殊帧标签名公开常量。
 *
 * <p>对应角色时间轴帧标签，供资源与玩法切换待机、攻击、受击、胜负等动作。</p>
 *
 * @see FighterHitRange
 * @see FighterActionState
 * @see FighterInputCmd
 */
public class FighterSpecialFrame {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 站立。
     *
     * @default 站立
     */
    public static const IDLE:String             = '站立';
    /**
     * 走（A/D）。
     *
     * @default 走
     */
    public static const MOVE:String             = '走';
    /**
     * 瞬步（L）。
     *
     * @default 瞬步
     */
    public static const DASH:String             = '瞬步';
    /**
     * 起跳。
     *
     * @default 起跳
     */
    public static const JUMP_START:String       = '起跳';
    /**
     * 跳（K）。
     *
     * @default 跳
     */
    public static const JUMP:String             = '跳';
    /**
     * 跳中。
     *
     * @default 跳中
     */
    public static const JUMP_ING:String         = '跳中';
    /**
     * 落。
     *
     * @default 落
     */
    public static const JUMP_DOWN:String        = '落';
    /**
     * 落地。
     *
     * @default 落地
     */
    public static const JUMP_TOUCH_FLOOR:String = '落地';

    /**
     * 跳砍（KJ）。
     *
     * @default 跳砍
     */
    public static const ATTACK_AIR:String  = '跳砍';
    /**
     * 跳招（KU）。
     *
     * @default 跳招
     */
    public static const SKILL_AIR:String   = '跳招';
    /**
     * 跳招-上（WKU）。
     *
     * @default 跳招-上
     */
    public static const SKILL_AIR_W:String = '跳招-上';
    /**
     * 跳招-下（SKU）。
     *
     * @default 跳招-下
     */
    public static const SKILL_AIR_S:String = '跳招-下';

    /**
     * 砍 1（J）。
     *
     * @default 砍1
     */
    public static const ATTACK:String = '砍1';

    /**
     * 砍技 1（SJ）。
     *
     * @default 砍技1
     */
    public static const SKILL_1:String = '砍技1';
    /**
     * 砍技 2（WJ）。
     *
     * @default 砍技2
     */
    public static const SKILL_2:String = '砍技2';

    /**
     * 招 1（U）。
     *
     * @default 招1
     */
    public static const ZHAO_1:String = '招1';
    /**
     * 招 2（SU）。
     *
     * @default 招2
     */
    public static const ZHAO_2:String = '招2';
    /**
     * 招 3（WU）。
     *
     * @default 招3
     */
    public static const ZHAO_3:String = '招3';

    /**
     * 必杀（I）。
     *
     * @default 必杀
     */
    public static const BISHA:String       = '必杀';
    /**
     * 上必杀（WI）。
     *
     * @default 上必杀
     */
    public static const BISHA_UP:String    = '上必杀';
    /**
     * 超必杀（SI）。
     *
     * @default 超必杀
     */
    public static const BISHA_SUPER:String = '超必杀';
    /**
     * 空中必杀（KI）。
     *
     * @default 空中必杀
     */
    public static const BISHA_AIR:String   = '空中必杀';

    /**
     * 摔 1（A/D + J）。
     *
     * @default 摔1
     */
    public static const CATCH_1:String = '摔1';
    /**
     * 摔 2（A/D + U）。
     *
     * @default 摔2
     */
    public static const CATCH_2:String = '摔2';

    /**
     * 防御（S）。
     *
     * @default 防御
     */
    public static const DEFENSE:String        = '防御';
    /**
     * 防御恢复。
     *
     * @default 防御恢复
     */
    public static const DEFENSE_RESUME:String = '防御恢复';

    /**
     * 被打。
     *
     * @default 被打
     */
    public static const HURT:String             = '被打';
    /**
     * 击飞。
     *
     * @default 击飞
     */
    public static const HURT_FLY:String         = '击飞';
    /**
     * 击飞_落。
     *
     * @default 击飞_落
     */
    public static const HURT_FALL:String        = '击飞_落';
    /**
     * 击飞_弹。
     *
     * @default 击飞_弹
     */
    public static const HURT_TAN:String         = '击飞_弹';
    /**
     * 击飞_倒。
     *
     * @default 击飞_倒
     */
    public static const HURT_DOWN:String        = '击飞_倒';
    /**
     * 击飞_起。
     *
     * @default 击飞_起
     */
    public static const HURT_DOWN_RESUME:String = '击飞_起';
    /**
     * 起身。
     *
     * @default 起身
     */
    public static const HURT_DOWN_JUMP:String   = '起身';

    /**
     * 万解（JK）。
     *
     * @default 万解
     */
    public static const BANKAI:String   = '万解';
    /**
     * 万解 W（WJK）。
     *
     * @default 万解W
     */
    public static const BANKAI_W:String = '万解W';
    /**
     * 万解 S（SJK）。
     *
     * @default 万解S
     */
    public static const BANKAI_S:String = '万解S';

    /**
     * 开场。
     *
     * @default 开场
     */
    public static const SAY_INTRO:String = '开场';
    /**
     * 胜利。
     *
     * @default 胜利
     */
    public static const WIN:String       = '胜利';
    /**
     * 失败。
     *
     * @default 失败
     */
    public static const LOSE:String      = '失败';
}
}
