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
 * 角色动作状态
 */
public class FighterActionState {
    include '../../../../../../../include/ImportVersion.as';

    /*----------------------------- 静态公有属性 -----------------------------*/

    // 正常
    public static const NORMAL:int = 0;
    // 硬直（后摇）endAct()
    public static const FREEZE:int = 40;

    // 正在普通攻击（J KJ）
    public static const ATTACK_ING:int      = 10;
    // 正在释放技能 （WJ SJ U WU SU KU）
    public static const SKILL_ING:int       = 11;
    // 正在释放必杀（I WI KI）
    public static const BISHA_ING:int       = 12;
    // 正在释放超必杀（SI）
    public static const BISHA_SUPER_ING:int = 13;

    // 正在跳跃（K）
    public static const JUMP_ING:int     = 14;
    // 正在瞬步（L）
    public static const DASH_ING:int     = 15;
    // 正在执行防反（防御反击，受击后触发）setHurtAction()
    public static const HURT_ACT_ING:int = 16;

    // 正在防御（S）
    public static const DEFENCE_ING:int   = 20;
    // 正在被打
    public static const HURT_ING:int      = 21;
    // 正在被击飞
    public static const HURT_FLYING:int   = 22;
    // 击飞后落地
    public static const HURT_DOWN:int     = 23;
    // 落地后弹起
    public static const HURT_DOWN_TAN:int = 24;

    // 死亡
    public static const DEAD:int = 30;

    // 正在万解/变身
    public static const WAN_KAI_ING:int = 50;
    // 正在执行开场
    public static const KAI_CHANG:int   = 60;
    // 正在执行胜利
    public static const WIN:int         = 61;
    // 正在执行失败
    public static const LOSE:int        = 62;

    /*----------------------------- 静态私有属性 -----------------------------*/

    // 不允许进行胜利的动作状态【必杀、超必杀，万解】
    private static const _isNotAllowWinStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(BISHA_ING, BISHA_SUPER_ING, WAN_KAI_ING);

        return states;
    })();

    // 正在处于必杀中的动作状态【必杀，超必杀】
    private static const _isBishaIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(BISHA_ING, BISHA_SUPER_ING);

        return states;
    })();

    // 正在处于攻击中的动作状态【普通攻击、释放技能，必杀，超必杀】
    private static const _isAttackIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(ATTACK_ING, SKILL_ING, BISHA_ING, BISHA_SUPER_ING);

        return states;
    })();

    // 正在处于被伤害中的动作状态【被打、击飞，击飞后落地，落地后弹起】
    private static const _isHurtIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(HURT_ING, HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN);

        return states;
    })();

    /*----------------------------- 静态公有方法 -----------------------------*/

    /**
     * 判断当前动作是否允许进行胜利（不在【必杀、超必杀，万解】动作状态）
     * @param actionState 当前动作
     * @return 当前动作是否允许进行胜利
     */
    public static function isAllowWinState(actionState:int):Boolean {
//        return actionState != BISHA_ING && actionState != BISHA_SUPER_ING && actionState != WAN_KAI_ING;
        return _isNotAllowWinStates.indexOf(actionState) == -1;
    }

    /**
     * 判断当前动作是否允许进行幽步（不在【必杀、超必杀，万解】动作状态）
     * @param actionState 当前动作
     * @return 当前动作是否允许进行幽步
     */
    public static function allowGhostStep(actionState:int):Boolean {
//        return actionState != BISHA_ING && actionState != BISHA_SUPER_ING && actionState != WAN_KAI_ING;
        return _isNotAllowWinStates.indexOf(actionState) == -1;
    }

    /**
     * 判断当前动作是否处于必杀中（在【必杀，超必杀】动作状态）
     * @param actionState 当前动作
     * @return 当前动作是否处于必杀中
     */
    public static function isBishaIng(actionState:int):Boolean {
        return _isBishaIngStates.indexOf(actionState) != -1;
    }

    /**
     * 判断当前动作是否处于攻击中（在【普通攻击、释放技能，必杀，超必杀】动作状态）
     * @param actionState 当前动作
     * @return 当前动作是否处于攻击中
     */
    public static function isAttacking(actionState:int):Boolean {
        return _isAttackIngStates.indexOf(actionState) != -1;
    }

    /**
     * 判断当前动作是否处于被伤害中（在【被打、击飞，击飞后落地，落地后弹起】动作状态）
     * @param actionState 当前动作
     * @return 当前动作是否处于被伤害中
     */
    public static function isHurting(actionState:int):Boolean {
        return _isHurtIngStates.indexOf(actionState) != -1;
    }

    /*----------------------------- 静态私有方法 -----------------------------*/

}
}
