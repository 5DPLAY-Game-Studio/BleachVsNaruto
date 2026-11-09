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

package net.play5d.game.bvn.interfaces {
/**
 * 角色一帧里要不要做某个动作。
 *
 * <p>返回 true 表示这一帧要执行。键盘实现看按键，AI 实现看自己的选择。
 * <code>jumpDown</code> 是向下跳，用来离开脚下的平台。<code>dashJump</code> 是冲刺跳，倒地起身也走它。</p>
 */
public interface IFighterActionCtrl {
    /**
     * 准备动作数据。
     */
    function initialize():void;

    /**
     * 推进动作逻辑。
     */
    function render():void;

    /**
     * 推进动作动画。
     */
    function renderAnimate():void;

    /**
     * 释放控制器。
     */
    function destroy():void;

    /**
     * 这一帧是否接受操作。
     *
     * @return 接受时为 true。
     */
    function enabled():Boolean;

    /**
     * 是否向左移动。
     *
     * @return 要执行时为 true。
     */
    function moveLEFT():Boolean;

    /**
     * 是否向右移动。
     *
     * @return 要执行时为 true。
     */
    function moveRIGHT():Boolean;

    /**
     * 是否防御。
     *
     * @return 要执行时为 true。
     */
    function defense():Boolean;

    /**
     * 是否攻击。
     *
     * @return 要执行时为 true。
     */
    function attack():Boolean;

    /**
     * 是否跳跃。
     *
     * @return 要执行时为 true。
     */
    function jump():Boolean;

    /**
     * 是否小跳。
     *
     * @return 要执行时为 true。
     */
    function jumpQuick():Boolean;

    /**
     * 是否向下跳。
     *
     * @return 要执行时为 true。
     */
    function jumpDown():Boolean;

    /**
     * 是否冲刺。
     *
     * @return 要执行时为 true。
     */
    function dash():Boolean;

    /**
     * 是否冲刺跳。倒地起身也走这个方法。
     *
     * @return 要执行时为 true。
     */
    function dashJump():Boolean;

    /**
     * 是否技能 1。
     *
     * @return 要执行时为 true。
     */
    function skill1():Boolean;

    /**
     * 是否技能 2。
     *
     * @return 要执行时为 true。
     */
    function skill2():Boolean;

    /**
     * 是否招式 1。
     *
     * @return 要执行时为 true。
     */
    function zhao1():Boolean;

    /**
     * 是否招式 2。
     *
     * @return 要执行时为 true。
     */
    function zhao2():Boolean;

    /**
     * 是否招式 3。
     *
     * @return 要执行时为 true。
     */
    function zhao3():Boolean;

    /**
     * 是否投技 1。
     *
     * @return 要执行时为 true。
     */
    function catch1():Boolean;

    /**
     * 是否投技 2。
     *
     * @return 要执行时为 true。
     */
    function catch2():Boolean;

    /**
     * 是否必杀。
     *
     * @return 要执行时为 true。
     */
    function bisha():Boolean;

    /**
     * 是否上必杀。
     *
     * @return 要执行时为 true。
     */
    function bishaUP():Boolean;

    /**
     * 是否超必杀。
     *
     * @return 要执行时为 true。
     */
    function bishaSUPER():Boolean;

    /**
     * 是否援助。
     *
     * @return 要执行时为 true。
     */
    function assist():Boolean;

    /**
     * 是否特殊技能。
     *
     * @return 要执行时为 true。
     */
    function specialSkill():Boolean;

    /**
     * 是否空中攻击。
     *
     * @return 要执行时为 true。
     */
    function attackAIR():Boolean;

    /**
     * 是否空中技能。
     *
     * @return 要执行时为 true。
     */
    function skillAIR():Boolean;

    /**
     * 是否空中必杀。
     *
     * @return 要执行时为 true。
     */
    function bishaAIR():Boolean;

    /**
     * 是否卍解。
     *
     * @return 要执行时为 true。
     */
    function banKai():Boolean;

    /**
     * 是否前向卍解。
     *
     * @return 要执行时为 true。
     */
    function banKaiW():Boolean;

    /**
     * 是否后向卍解。
     *
     * @return 要执行时为 true。
     */
    function banKaiS():Boolean;

    /**
     * 是否幽步。
     *
     * @return 要执行时为 true。
     */
    function ghostStep():Boolean;

    /**
     * 是否幽步上跳。
     *
     * @return 要执行时为 true。
     */
    function ghostJump():Boolean;

    /**
     * 是否幽步下跳。
     *
     * @return 要执行时为 true。
     */
    function ghostJumpDown():Boolean;
}
}
