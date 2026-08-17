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

package net.play5d.game.bvn.ui.select.flow {

/**
 * 选人流程步进动作（由 <code>SelectFighterStage</code> 执行）。
 *
 * @see ISelectModeFlow
 */
public class SelectFlowAction {

    /** 无动作（仅更新步号时不用） */
    public static const NONE:int = 0;
    /** 初始化角色列表与选人器 */
    public static const INIT_FIGHTER:int = 1;
    /** 关闭 P1 光标并开启 P2（P1 键位控 P2，用于 CPU/观战侧选人） */
    public static const ENABLE_P2_WITH_P1_INPUT:int = 2;
    /** 淡出列表后进入援助选人 */
    public static const FADOUT_ASSIST:int = 3;
    /** 淡出列表后进入地图选择 */
    public static const FADOUT_MAP:int = 4;
    /** 闯关开局 */
    public static const START_ARCADE:int = 5;
    /** 无双开局 */
    public static const START_MUSOU:int = 6;
    /** 选人完成进入加载 */
    public static const SELECT_FINISH:int = 7;

    /**
     * 动作类型，见本类常量。
     */
    public var action:int = NONE;

    /**
     * 执行后写入的 <code>_curStep</code>；若为 <code>-1</code> 表示不改步号。
     */
    public var nextStep:int = -1;

    /**
     * 构造动作。
     *
     * @param action 动作类型。
     * @param nextStep 下一步；默认 <code>-1</code> 不改。
     * @example
     * <listing version="3.0">
     * var a:SelectFlowAction = new SelectFlowAction(SelectFlowAction.INIT_FIGHTER, 1);
     * </listing>
     */
    public function SelectFlowAction(action:int = 0, nextStep:int = -1) {
        this.action   = action;
        this.nextStep = nextStep;
    }
}
}
