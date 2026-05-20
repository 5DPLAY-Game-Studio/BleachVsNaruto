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

package {

/**
 * 全局函数，使用命名占位符格式化字符串并 trace 输出（无调试前缀）。
 * 始终调用 <code>Format(format, params)</code>；模板含 <code>{name}</code> 而 <code>params</code> 缺键时将抛出 <code>ArgumentError</code>。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Printf()</code> 输出格式化字符串：
 * <listing version="3.0">  
 var format:String = "今天是星期{weekday}，天气：{weather}";
 var params:Object = {weekday: 1, weather: "晴"};

 // 输出结果：“今天是星期1，天气：晴”
 Printf(format, params);
 * </listing>
 *
 * @param           format  源字符串
 * @param           params  占位符名到替换值的映射，可为 null
 * 
 * @see             String
 * @see             Object
 * @throws          ArgumentError
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function Printf(format:String, params:Object = null):void {
    trace(Format(format, params));
}
}
