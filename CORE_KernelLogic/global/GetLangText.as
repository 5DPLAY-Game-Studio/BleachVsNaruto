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
import net.play5d.game.bvn.utils.MultiLangUtils;

/**
 * 全局函数，按点分树形路径从语言包取得原始文案（不替换命名占位符）。
 * <p/>
 * 文案来自 <code>config/language/{locale}.json</code>，由 <code>MultiLangUtils</code> 加载。
 * 若需替换 <code>{name}</code> 占位符，请使用 <code>GetLang(tree, params)</code>。
 * <p/>
 * 下列代码演示如何使用全局方法 <code>GetLangText()</code> 取得当前语言模板：
 * <listing version="3.0">
 // 无占位符
 trace(GetLangText('debug.trace.prefix'));

 // 含命名占位符的模板（此处仍为原文，未格式化）
 trace(GetLangText('alert.musou_ctrl.need_more_money'));
 * </listing>
 *
 * @param           tree    点分树形路径（如 <code>debug.trace.prefix</code>）
 *
 * @see             String
 * @see             GetLang
 * @see             MultiLangUtils
 * @return          语言包中的原始字符串；未找到时为 <code>[N/A]</code>
 *
 * @langversion     3.0
 * @playerversion   Flash 9, Lite 4
 */
public function GetLangText(tree:String):String {
    // 从多语言工具按树形路径查询
    var langText:String = MultiLangUtils.I.getLangText(tree);
    // 未加载或路径不存在时使用占位默认值
    langText ||= '[N/A]';

    return langText;
}
}
