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
 * 全局函数，输出带前缀的、基于语言包且支持命名占位符的调试信息。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>TraceLang()</code> 输出带前缀的、基于语言包且支持命名占位符的调试信息：
 * <listing version="3.0">
 var tree:String = "debug.trace.prefix";

 // 输出结果：“* 跟踪 : ”
 TraceLang(tree);
 * </listing>
 *
 * @param           tree   文本的树形路径
 * @param           params 占位符名到替换值的映射，可为 null
 * 
 * @see             String
 * @see             Object
 * @throws          ArgumentError
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function TraceLang(tree:String, params:Object = null):void {
    Trace(GetLang(tree, params));
}
}
