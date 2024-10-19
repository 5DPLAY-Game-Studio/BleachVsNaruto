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
 * 全局函数，格式化字符串，使用 “<b>{}</b>” 符号作为占位符
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Format()</code> 格式化字符串：
 * <listing version="3.0">
 var source:String = "今天是星期{}，天气：{}";
 var output:String = Format(source, 1, "晴");

 // 输出结果：“今天是星期1，天气：晴”
 trace(output);
 * </listing>
 *
 * @param         format 源字符串
 * @param         args   打印的参数列表
 *
 * @see           String
 * @see           Array
 * @throws        ArgumentError
 * @return        格式化处理后的字符串
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function Format(format:String, ...args):String {
    const SEPARATOR:String = '{}';

    // 如果在格式化字符串内没有找到分隔符 “{}”
    // 则原样打印
    if (format.indexOf(SEPARATOR) == -1) {
        return format;
    }

    // 将字符串以分隔符 “{}” 为分隔，分割成数组
    var array:Array = format.split(SEPARATOR) as Array;
    if (!array) {
        return null;
    }

//    trace(array);

    var arrLen:int  = array.length;
    var argsLen:int = args.length;

    // 判断格式化字符串的分割长度是否和参数列表长度一致
    if (arrLen - 1 != argsLen) {
        // 不一致抛出“参数错误”异常
        throw new ArgumentError(
                'The variadic length does not match the formatted string length!'
        );
    }

    // 最终输出消息
    var msg:String = array[0];
    for (var i:int = 0; i < argsLen; i++) {
        msg += args[i];
        msg += array[i + 1];
    }

    return msg;
}
}
