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
 * 选人模式流程：步进、是否双人选人器、是否等待双方完成。
 *
 * @see SelectModeFlowFactory
 * @see SelectFlowAction
 */
public interface ISelectModeFlow {
    /**
     * 是否创建 <code>GameData.I.p2Select</code>。
     *
     * @return 需要 P2 选人数据为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (flow.createP2SelectVO()) {
     *     // ...
     * }
     * </listing>
     */
    function createP2SelectVO():Boolean;

    /**
     * 进角选/援助时是否同时初始化 P1+P2 选人器。
     *
     * @return 双人同时选为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (flow.initBothSelecters()) {
     *     // ...
     * }
     * </listing>
     */
    function initBothSelecters():Boolean;

    /**
     * 单人完成选择后是否需等另一方（双人对战）。
     *
     * @return 需双方齐完为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (flow.shouldWaitBothPlayers()) {
     *     // ...
     * }
     * </listing>
     */
    function shouldWaitBothPlayers():Boolean;

    /**
     * 解析当前步进应执行的动作。
     *
     * @param curStep 当前步号。
     * @return 动作描述。
     * @example
     * <listing version="3.0">
     * var a:SelectFlowAction = flow.resolveNextStep(0);
     * </listing>
     */
    function resolveNextStep(curStep:int):SelectFlowAction;
}
}
