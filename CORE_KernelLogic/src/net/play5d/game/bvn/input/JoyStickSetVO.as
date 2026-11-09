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

package net.play5d.game.bvn.input {
/**
 * 手柄单键映射（控件 id + 轴/阈值方向）。
 *
 * @see JoyStickConfigVO
 * @see JoyStick
 */
public class JoyStickSetVO {
    /**
     * 按控件序号和方向建一条映射。不传方向时记 1。
     *
     * @param id 控件索引。
     * @param value 正数、负数或按钮标记。默认 1。
     */
    public function JoyStickSetVO(id:int, value:Number = 1) {
        this.id    = id;
        this.value = value;
    }

    /**
     * 控件索引。
     */
    public var id:int;
    /**
     * 轴方向或按钮值。构造时不传则是 1。
     */
    public var value:Number = 0;

    /**
     * 写入控件序号和值。
     *
     * @param o 含 <code>id</code> 和 <code>value</code>。null 时抛错。
     * @throws TypeError <code>o</code> 为 null 时。
     * @example
     * <listing version="3.0">
     * key.readObj(saved);
     * </listing>
     */
    public function readObj(o:Object):void {
        this.id    = o.id;
        this.value = o.value;
    }

    /**
     * 导出控件序号和值。
     *
     * @return 含 <code>id</code> 和 <code>value</code> 的对象。
     * @example
     * <listing version="3.0">
     * var saved:Object = key.toObj();
     * </listing>
     */
    public function toObj():Object {
        var o:Object = {};
        o.id         = this.id;
        o.value      = this.value;

        return o;
    }
}
}
