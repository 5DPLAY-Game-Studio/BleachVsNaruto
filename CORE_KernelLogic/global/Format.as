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
 * 全局函数，使用命名占位符 “<b>{name}</b>” 格式化字符串。
 * 若要表示字面量的大括号请写作 <code>{{</code> 与 <code>}}</code>。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Format()</code> 格式化字符串：
 * <listing version="3.0">
 var source:String = "今天是星期{weekday}，天气：{weather}";
 var params:Object = {weekday: 1, weather: "晴"};
 var output:String = Format(source, params);

 // 输出结果：“今天是星期1，天气：晴”
 trace(output);
 * </listing>
 *
 * @param           format  源字符串
 * @param           params  占位符名到替换值的映射，可为 null
 *
 * @see             String
 * @see             Object
 * @throws          ArgumentError
 * @return          基于命名占位符格式化处理后的字符串
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function Format(format:String, params:Object = null):String {
    // 如果格式为空或不包含大括号，则返回原字符串
    if (!format || format.indexOf('{') == -1) {
        return format;
    }

    // 如果参数为空，则设置为空对象
    params ||= {};

    // 使用正则表达式匹配命名占位符
    const PLACEHOLDER:RegExp = /\{([a-zA-Z_][a-zA-Z0-9_]*)\}/g;     // 匹配命名占位符
    const ESCAPE_OPEN:String  = '\u0001';                           // 转义左大括号
    const ESCAPE_CLOSE:String = '\u0002';                           // 转义右大括号

    // 转义左大括号和右大括号
    var work:String = format;
    work = work.split('{{').join(ESCAPE_OPEN);
    work = work.split('}}').join(ESCAPE_CLOSE);

    // 替换命名占位符
    var missing:Array = [];
    var result:String = work.replace(PLACEHOLDER, function (...rest):String {
        // 获取命名占位符的名称
        var name:String = rest[1];
        // 如果参数中没有该命名占位符，则将该命名占位符添加到缺失的命名占位符数组中
        if (!params.hasOwnProperty(name)) {
            missing[missing.length] = name;

            // 返回原始的命名占位符
            return '{' + name + '}';
        }

        // 返回命名占位符的值
        return String(params[name]);
    });

    // 还原转义的大括号
    result = result.split(ESCAPE_OPEN).join('{');
    result = result.split(ESCAPE_CLOSE).join('}');

    // 如果缺失的命名占位符数量大于0，则抛出异常
    if (missing.length > 0) {
        throw new ArgumentError(
                'Format: missing parameter(s): ' + missing.join(', ')
        );
    }

    return result;
}
}
