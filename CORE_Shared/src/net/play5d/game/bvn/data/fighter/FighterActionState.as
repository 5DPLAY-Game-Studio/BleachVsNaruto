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
 * 角色动作状态公开常量与判定。
 *
 * <p>整型常量供资源与玩法共用；静态判定方法仅做集合查询，不含战斗推进逻辑。</p>
 *
 * @see FighterSpecialFrame
 * @see #isAllowWinState()
 */
public class FighterActionState {
    include '../../../../../../../include/ImportVersion.as';

    /** 正常 */
    public static const NORMAL:int = 0;
    /** 硬直（动作结束后摇） */
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
    /** 正在执行受击触发动作（如反击等） */
    public static const HURT_ACT_ING:int = 16;

    /** 正在防御（S） */
    public static const DEFENSE_ING:int   = 20;
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
    private static const _isNotAllowWinStates:Vector.<int> = new <int>[
        BISHA_ING, BISHA_SUPER_ING, WAN_KAI_ING
    ];

    /** @private 正在处于必杀中的动作状态（必杀、超必杀） */
    private static const _isBishaIngStates:Vector.<int> = new <int>[
        BISHA_ING, BISHA_SUPER_ING
    ];

    /** @private 正在处于攻击中的动作状态（普通攻击、技能、必杀、超必杀） */
    private static const _isAttackIngStates:Vector.<int> = new <int>[
        ATTACK_ING, SKILL_ING, BISHA_ING, BISHA_SUPER_ING
    ];

    /** @private 正在处于被伤害中的动作状态（被打、击飞、落地、弹起） */
    private static const _isHurtIngStates:Vector.<int> = new <int>[
        HURT_ING, HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN
    ];

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
     * 判断当前动作是否允许幽步。
     *
     * <p>历史别名，实现与 <code>isAllowWinState</code> 相同（均排除必杀、超必杀、万解）。</p>
     *
     * @param actionState 当前动作状态。
     * @return 允许时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * FighterActionState.allowGhostStep(FighterActionState.NORMAL); // true
     * </listing>
     * @see #isAllowWinState()
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
