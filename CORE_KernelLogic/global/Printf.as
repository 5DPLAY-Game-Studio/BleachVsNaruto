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
 * 使用命名占位符格式化字符串并 <code>trace</code> 输出（无调试前缀）。
 *
 * <p>始终调用 <code>Format(format, params)</code>；占位符缺键时抛出 <code>ArgumentError</code>。
 * 不受 <code>GameLogger</code> 阈值影响。</p>
 *
 * @param format 源字符串。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @throws ArgumentError 由 <code>Format</code> 在缺键时抛出。
 * @example
 * <listing version="3.0">
 * Printf('今天是星期{weekday}，天气：{weather}', {weekday: 1, weather: '晴'});
 * // 输出：今天是星期1，天气：晴
 * </listing>
 * @see Format
 * @see Trace
 */
public function Printf(format:String, params:Object = null):void {
    trace(Format(format, params));
}
}
