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
     * @param id 控件索引。
     * @param value 轴方向阈值符号（正/负）或按钮标记。
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
     * 轴方向 / 按钮值。
     * @default 0
     */
    public var value:Number = 0;

    /**
     * 从普通对象读取。
     * @param o 含 <code>id</code> / <code>value</code>。
     */
    public function readObj(o:Object):void {
        this.id    = o.id;
        this.value = o.value;
    }

    /**
     * 导出为普通对象。
     * @return 含 <code>id</code> / <code>value</code>。
     */
    public function toObj():Object {
        var o:Object = {};
        o.id         = this.id;
        o.value      = this.value;

        return o;
    }
}
}
