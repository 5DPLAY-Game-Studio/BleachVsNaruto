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

package net.play5d.game.bvn.data.lan {
/**
 * Socket 同步按键缓冲（公开属性 + <code>clear</code>）。
 *
 * <p>Pc/Mob 共用字段形状；Mob 额外使用 <code>select</code>/<code>back</code>。不含网络收发。</p>
 */
public class SocketInputData {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 构造空缓冲。
     * @example
     * <listing version="3.0">
     * var input:SocketInputData = new SocketInputData();
     * </listing>
     */
    public function SocketInputData() {
    }

    /**
     * 上。
     * @default false
     */
    public var up:Boolean;
    /**
     * 下。
     * @default false
     */
    public var down:Boolean;
    /**
     * 左。
     * @default false
     */
    public var left:Boolean;
    /**
     * 右。
     * @default false
     */
    public var right:Boolean;
    /**
     * 攻击。
     * @default false
     */
    public var attack:Boolean;
    /**
     * 跳跃。
     * @default false
     */
    public var jump:Boolean;
    /**
     * 冲刺。
     * @default false
     */
    public var dash:Boolean;
    /**
     * 技能。
     * @default false
     */
    public var skill:Boolean;
    /**
     * 大招。
     * @default false
     */
    public var superSkill:Boolean;
    /**
     * 特殊。
     * @default false
     */
    public var special:Boolean;
    /**
     * 确认/选择（主要 Mob）。
     * @default false
     */
    public var select:Boolean;
    /**
     * 返回（主要 Mob）。
     * @default false
     */
    public var back:Boolean;

    /**
     * 清空全部按键标记。
     * @example
     * <listing version="3.0">
     * input.clear();
     * </listing>
     */
    public function clear():void {
        up    = false;
        down  = false;
        left  = false;
        right = false;

        attack     = false;
        jump       = false;
        dash       = false;
        skill      = false;
        superSkill = false;
        special    = false;

        select = false;
        back   = false;
    }
}
}
