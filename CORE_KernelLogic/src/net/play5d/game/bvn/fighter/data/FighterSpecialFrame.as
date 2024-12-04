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
/**
 * 角色特殊帧
 */
public class FighterSpecialFrame {
    include '../../../../../../../include/_INCLUDE_.as';

    // 站立
    public static const IDLE:String             = '站立';
    // 走 A/D
    public static const MOVE:String             = '走';
    // 瞬步 L
    public static const DASH:String             = '瞬步';
    // 起跳
    public static const JUMP_START:String       = '起跳';
    // 跳 K
    public static const JUMP:String             = '跳';
    // 跳中
    public static const JUMP_ING:String         = '跳中';
    // 落
    public static const JUMP_DOWN:String        = '落';
    // 落地
    public static const JUMP_TOUCH_FLOOR:String = '落地';

    // 跳砍 KJ
    public static const ATTACK_AIR:String = '跳砍';
    // 跳招 KU
    public static const SKILL_AIR:String  = '跳招';
    // 跳招-上 WKU
    public static const SKILL_AIR_W:String  = '跳招-上';
    // 跳招-下 SKU
    public static const SKILL_AIR_S:String  = '跳招-下';

    // 砍1 J
    public static const ATTACK:String = '砍1';

    // 砍技1 SJ
    public static const SKILL_1:String = '砍技1';
    // 砍技2 WJ
    public static const SKILL_2:String = '砍技2';

    // 招1 U
    public static const ZHAO_1:String = '招1';
    // 招2 SU
    public static const ZHAO_2:String = '招2';
    // 招3 WU
    public static const ZHAO_3:String = '招3';

    // 必杀 I
    public static const BISHA:String       = '必杀';
    // 上必杀 WI
    public static const BISHA_UP:String    = '上必杀';
    // 超必杀 SI
    public static const BISHA_SUPER:String = '超必杀';
    // 空中必杀 KI
    public static const BISHA_AIR:String   = '空中必杀';

    // 摔1 A/D J
    public static const CATCH_1:String = '摔1';
    // 摔2 A/D U
    public static const CATCH_2:String = '摔2';

    // 防御 S
    public static const DEFENSE:String        = '防御';
    // 防御恢复
    public static const DEFENSE_RESUME:String = '防御恢复';
    // 防住
//    public static const DEFENSE_HIT:String    = '防住';

    // 被打
    public static const HURT:String             = '被打';
    // 击飞
    public static const HURT_FLY:String         = '击飞';
    // 击飞_落
    public static const HURT_FALL:String        = '击飞_落';
    // 击飞_弹
    public static const HURT_TAN:String         = '击飞_弹';
    // 击飞_倒
    public static const HURT_DOWN:String        = '击飞_倒';
    // 击飞_起
    public static const HURT_DOWN_RESUME:String = '击飞_起';
    // 起身
    public static const HURT_DOWN_JUMP:String   = '起身';

    // 万解 JK
    public static const BANKAI:String   = '万解';
    // 万解W WJK
    public static const BANKAI_W:String = '万解W';
    // 万解S SJK
    public static const BANKAI_S:String = '万解S';

    // 开场
    public static const SAY_INTRO:String = '开场';
    // 胜利
    public static const WIN:String       = '胜利';
    // 失败
    public static const LOSE:String      = '失败';
}
}
