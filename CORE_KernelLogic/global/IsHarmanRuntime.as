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
 * 判断当前是否为 Harman 运行时。
 *
 * <p>主版本号 &gt;= 33 视为 Harman 运行时；结果进程内缓存于函数对象。
 * <code>GetRuntimeType</code> 这次解析失败时，会把「不是 Harman」缓存下来，之后不再重试。</p>
 *
 * @return 主版本号 &gt;= 33 时为 <code>true</code>，否则为 <code>false</code>。
 * @example
 * <listing version="3.0">
 * if (IsHarmanRuntime()) {
 *     // Harman AIR / Flash Player 33+
 * }
 * </listing>
 * @see GetRuntimeType
 */
public function IsHarmanRuntime():Boolean {
    // 缓存挂在函数对象上，避免包级第二外部可见定义
    if (IsHarmanRuntime['_c'] != null) {
        return IsHarmanRuntime['_c'];
    }
    var t:Object = GetRuntimeType();
    IsHarmanRuntime['_c'] = t != null && int(t.majorVersion) >= 33;
    return IsHarmanRuntime['_c'];
}
}
