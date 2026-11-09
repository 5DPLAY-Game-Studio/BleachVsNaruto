/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.game.bvn.utils.InstanceVOClone;

/**
 * 浅克隆当前值对象。
 *
 * <p>只复制公开变量，嵌套对象仍是同一引用。构造参数最多两个。调试环境下多出来的参数会抛出 <code>ArgumentError</code>。发行环境只记一条错误，随后对空实例写属性时会抛错。</p>
 *
 * @param arg 传给新实例构造函数的参数，最多两个。
 * @return 同类型的新实例。
 * @throws ArgumentError 调试环境下参数超过两个。
 * @example
 * <listing version="3.0">
 * var copy:IInstanceVO = vo.clone();
 * var copy2:IInstanceVO = vo.clone(vo.id);
 * </listing>
 * @see net.play5d.game.bvn.utils.InstanceVOClone
 */
public function clone(...arg):IInstanceVO {
    return InstanceVOClone.clone(this, arg);
}