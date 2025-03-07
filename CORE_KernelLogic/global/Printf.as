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
 * 全局函数，输出格式化字符串，使用 “<b>{}</b>” 符号作为占位符
 * <p/>
 * 下列代码演示如何使用全局方法 <code>Printf()</code> 输出格式化字符串：
 * <listing version="3.0">
 var source:String = "今天是星期{}，天气：{}";

 // 输出结果：“今天是星期1，天气：晴”
 Printf(source, 1, "晴");
 * </listing>
 *
 * @param         format 源字符串
 * @param         args   打印的参数列表
 *
 * @see           String
 * @see           Array
 * @throws        ArgumentError
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function Printf(format:String, ...args):void {
    trace(Format.apply(null, [format].concat(args.toString().split(","))));
}
}
