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
import flash.system.Capabilities;

/**
 * 解析当前播放器/运行时版本字符串。
 *
 * <p>解析成功后缓存于函数对象。版本串不符合 <code>平台 主,次,生成,内部</code> 时返回
 * <code>null</code>，并且不写入缓存，下次还会再解析。</p>
 *
 * @return 含下列字段的对象；失败时为 <code>null</code>：
 * <ul>
 *   <li><code>platform</code> — <code>WIN</code> / <code>MAC</code> / <code>LNX</code> / <code>AND</code></li>
 *   <li><code>majorVersion</code> — 主版本号字符串</li>
 *   <li><code>minorVersion</code> — 次版本号字符串</li>
 *   <li><code>buildNumber</code> — 生成版本号</li>
 *   <li><code>internalBuildNumber</code> — 内部生成版本号</li>
 * </ul>
 * @example
 * <listing version="3.0">
 * var t:Object = GetRuntimeType();
 * if (t) {
 *     trace(t.platform, t.majorVersion);
 * }
 * </listing>
 * @see IsHarmanRuntime
 * @see flash.system.Capabilities#version
 */
public function GetRuntimeType():Object {
    // 缓存挂在函数对象上，避免包级第二外部可见定义
    if (GetRuntimeType['_c'] != null) {
        return GetRuntimeType['_c'];
    }

    var tmp:Array = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/.exec(Capabilities.version) as Array;
    if (!tmp) {
        return null;
    }

    GetRuntimeType['_c'] = {
        platform           : tmp[1],
        majorVersion       : tmp[2],
        minorVersion       : tmp[3],
        buildNumber        : tmp[4],
        internalBuildNumber: tmp[5]
    };
    return GetRuntimeType['_c'];
}
}
