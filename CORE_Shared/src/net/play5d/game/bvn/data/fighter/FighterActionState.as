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
 * 角色动作状态。
 *
 * <p>用整型常量表示当前动作阶段，并提供若干状态判定静态方法。</p>
 *
 * @see FighterSpecialFrame
 * @see FighterHurtType
 */
public class FighterActionState {
    include '../../../../../../../include/ImportVersion.as';

    /** 正常 */
    public static const NORMAL:int = 0;
    /** 硬直（后摇，<code>endAct()</code>） */
    public static const FREEZE:int = 40;

    /** 正在普通攻击（J / KJ） */
    public static const ATTACK_ING:int      = 10;
    /** 正在释放技能（WJ / SJ / U / WU / SU / KU） */
    public static const SKILL_ING:int       = 11;
    /** 正在释放必杀（I / WI / KI） */
    public static const BISHA_ING:int       = 12;
    /** 正在释放超必杀（SI） */
    public static const BISHA_SUPER_ING:int = 13;

    /** 正在跳跃（K） */
    public static const JUMP_ING:int     = 14;
    /** 正在瞬步（L） */
    public static const DASH_ING:int     = 15;
    /** 正在执行防反（受击后触发，<code>setHurtAction()</code>） */
    public static const HURT_ACT_ING:int = 16;

    /** 正在防御（S） */
    public static const DEFENCE_ING:int   = 20;
    /** 正在被打 */
    public static const HURT_ING:int      = 21;
    /** 正在被击飞 */
    public static const HURT_FLYING:int   = 22;
    /** 击飞后落地 */
    public static const HURT_DOWN:int     = 23;
    /** 落地后弹起 */
    public static const HURT_DOWN_TAN:int = 24;

    /** 死亡 */
    public static const DEAD:int = 30;

    /** 正在万解/变身 */
    public static const WAN_KAI_ING:int = 50;
    /** 正在执行开场 */
    public static const KAI_CHANG:int   = 60;
    /** 正在执行胜利 */
    public static const WIN:int         = 61;
    /** 正在执行失败 */
    public static const LOSE:int        = 62;

    /** @private 不允许进行胜利的动作状态（必杀、超必杀、万解） */
    private static const _isNotAllowWinStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(BISHA_ING, BISHA_SUPER_ING, WAN_KAI_ING);

        return states;
    })();

    /** @private 正在处于必杀中的动作状态（必杀、超必杀） */
    private static const _isBishaIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(BISHA_ING, BISHA_SUPER_ING);

        return states;
    })();

    /** @private 正在处于攻击中的动作状态（普通攻击、技能、必杀、超必杀） */
    private static const _isAttackIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(ATTACK_ING, SKILL_ING, BISHA_ING, BISHA_SUPER_ING);

        return states;
    })();

    /** @private 正在处于被伤害中的动作状态（被打、击飞、落地、弹起） */
    private static const _isHurtIngStates:Vector.<int> = (function ():Vector.<int> {
        var states:Vector.<int> = new Vector.<int>();
        states.push(HURT_ING, HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN);

        return states;
    })();

    /**
     * 判断当前动作是否允许进入胜利（不在必杀、超必杀、万解中）。
     *
     * @param actionState 当前动作状态。
     * @return 允许时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.isAllowWinState(FighterActionState.NORMAL); // true
     * </listing>
     */
    public static function isAllowWinState(actionState:int):Boolean {
        return _isNotAllowWinStates.indexOf(actionState) == -1;
    }

    /**
     * 判断当前动作是否允许幽步（不在必杀、超必杀、万解中）。
     *
     * @param actionState 当前动作状态。
     * @return 允许时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.allowGhostStep(FighterActionState.NORMAL); // true
     * </listing>
     */
    public static function allowGhostStep(actionState:int):Boolean {
        return _isNotAllowWinStates.indexOf(actionState) == -1;
    }

    /**
     * 判断当前动作是否处于必杀中（必杀或超必杀）。
     *
     * @param actionState 当前动作状态。
     * @return 处于必杀中时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.isBishaIng(FighterActionState.BISHA_ING); // true
     * </listing>
     */
    public static function isBishaIng(actionState:int):Boolean {
        return _isBishaIngStates.indexOf(actionState) != -1;
    }

    /**
     * 判断当前动作是否处于攻击中（普通攻击、技能、必杀、超必杀）。
     *
     * @param actionState 当前动作状态。
     * @return 处于攻击中时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.isAttacking(FighterActionState.ATTACK_ING); // true
     * </listing>
     */
    public static function isAttacking(actionState:int):Boolean {
        return _isAttackIngStates.indexOf(actionState) != -1;
    }

    /**
     * 判断当前动作是否处于被伤害中（被打、击飞、落地、弹起）。
     *
     * @param actionState 当前动作状态。
     * @return 处于被伤害中时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.isHurting(FighterActionState.HURT_ING); // true
     * </listing>
     */
    public static function isHurting(actionState:int):Boolean {
        return _isHurtIngStates.indexOf(actionState) != -1;
    }
}
}
