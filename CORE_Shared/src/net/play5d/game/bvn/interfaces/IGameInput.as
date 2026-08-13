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

package net.play5d.game.bvn.interfaces {
import flash.display.Stage;

/**
 * 游戏输入设备注入契约。
 *
 * <p>由壳或玩法侧提供键盘 / 手柄 / 触屏 / 联机通道等实现，经入口注入后供菜单与对局查询按键状态。</p>
 *
 * @example
 * <listing version="3.0">
 * var input:IGameInput = keyInput;
 * input.initlize(stage);
 * input.enabled = true;
 * if (input.attack()) {
 *     // ...
 * }
 * </listing>
 */
public interface IGameInput {
    /**
     * 是否启用输入。
     * @return 启用为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.enabled) {
     *     input.focus();
     * }
     * </listing>
     */
    function get enabled():Boolean;

    /**
     * @private
     */
    function set enabled(v:Boolean):void;

    /**
     * 绑定舞台并完成初始化。
     * @param stage 当前舞台。
     * @example
     * <listing version="3.0">
     * input.initlize(stage);
     * </listing>
     */
    function initlize(stage:Stage):void;

    /**
     * 应用键位或设备配置。
     * @param config 实现相关的配置对象。
     * @example
     * <listing version="3.0">
     * input.setConfig(cfg);
     * </listing>
     */
    function setConfig(config:Object):void;

    /**
     * 取得输入焦点（如重新监听按键）。
     * @example
     * <listing version="3.0">
     * input.focus();
     * </listing>
     */
    function focus():void;

    /**
     * 是否有任意键按下。
     * @return 有按键为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.anyKey()) {
     *     // ...
     * }
     * </listing>
     */
    function anyKey():Boolean;

    /**
     * 返回 / 取消。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.back()) {
     *     // ...
     * }
     * </listing>
     */
    function back():Boolean;

    /**
     * 确认 / 选择。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.select()) {
     *     // ...
     * }
     * </listing>
     */
    function select():Boolean;

    /**
     * 上。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.up()) {
     *     // ...
     * }
     * </listing>
     */
    function up():Boolean;

    /**
     * 下。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.down()) {
     *     // ...
     * }
     * </listing>
     */
    function down():Boolean;

    /**
     * 左。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.left()) {
     *     // ...
     * }
     * </listing>
     */
    function left():Boolean;

    /**
     * 右。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.right()) {
     *     // ...
     * }
     * </listing>
     */
    function right():Boolean;

    /**
     * 攻击。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.attack()) {
     *     // ...
     * }
     * </listing>
     */
    function attack():Boolean;

    /**
     * 跳跃。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.jump()) {
     *     // ...
     * }
     * </listing>
     */
    function jump():Boolean;

    /**
     * 冲刺 / 疾走。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.dash()) {
     *     // ...
     * }
     * </listing>
     */
    function dash():Boolean;

    /**
     * 技能。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.skill()) {
     *     // ...
     * }
     * </listing>
     */
    function skill():Boolean;

    /**
     * 必杀。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.superSkill()) {
     *     // ...
     * }
     * </listing>
     */
    function superSkill():Boolean;

    /**
     * 特殊。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.special()) {
     *     // ...
     * }
     * </listing>
     */
    function special():Boolean;

    /**
     * 万解 / 变身类按键。
     * @return 按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.wankai()) {
     *     // ...
     * }
     * </listing>
     */
    function wankai():Boolean;

    /**
     * 清空缓冲或瞬时状态。
     * @example
     * <listing version="3.0">
     * input.clear();
     * </listing>
     */
    function clear():void;
}
}
