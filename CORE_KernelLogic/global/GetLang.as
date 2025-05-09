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
 * 全局函数，得到基于树形路径的格式化后的当前语言
 * <p/>
 * 下列代码演示如何使用全局方法 <code>GetLang()</code> 输出格式化后的当前语言：
 * <listing version="3.0">
 var tree:String = "debug.trace.prefix";

 // 输出结果：“* 跟踪 : ”
 trace(GetLang(tree));
 * </listing>
 *
 * @param         tree 文本的树形路径
 * @param         args 打印的参数列表
 *
 * @see           String
 * @see           Array
 * @throws        ArgumentError
 * @return        基于树形路径的格式化后的当前语言
 *
 * @langversion   3.0
 * @playerversion Flash 9, Lite 4
 */
public function GetLang(tree:String, ...args):String {
    // 当前语言文本
    var langText:String = GetLangText(tree);
    // 格式化后的当前语言
    var format:String   = Format.apply(null, [langText].concat(args.toString().split(",")));

    return format;
}
}
