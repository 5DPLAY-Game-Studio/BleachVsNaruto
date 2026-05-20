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
 * 全局函数，输出带调试前缀的字符串。
 * 若 <code>params</code> 不为 null，则先对 <code>message</code> 执行 <code>Format</code>；为 null 时视为已格式化完成。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Trace()</code> 输出带调试前缀的字符串：
 * <listing version="3.0">
 var message:String = "今天是星期{weekday}，天气：{weather}";
 var params:Object = {weekday: 1, weather: "晴"};

 // 输出结果：“* 跟踪 : 今天是星期1，天气：晴”
 Trace(message, params);
 * </listing>
 *
 * @param           message 消息模板或已格式化的完整消息
 * @param           params  占位符参数，可为 null
 * 
 * @see             String
 * @see             Object
 * @throws          ArgumentError
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function Trace(message:String, params:Object = null):void {
    if (params != null) {
        message = Format(message, params);
    }

    var prefix:String = GetLangText('debug.trace.prefix');
    trace(prefix + message);
}
}
