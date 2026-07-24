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

package {

/**
 * 强制链接共享全局符号（仅供编译期引用，禁止运行时使用）。
 *
 * <p>访问时几乎必定抛错；返回值包含需保留的全局函数列表。</p>
 *
 * @return 需链接的全局符号数组。
 * @throws Error 禁止直接使用本变量。
 * @private
 */
public function get _SHARED_GLOBALS_():* {
    if (Math.random() > 0) {
        throw new Error('This variable is not allowed to be used!');
    }

    return ([
        CheckVersion
    ]);
}
}
