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
import net.play5d.game.bvn.utils.MultiLangUtils;

/**
 * 按点分树形路径从语言包取得原始文案（不替换命名占位符）。
 *
 * <p>文案来自 <code>config/language/{locale}.json</code>，由
 * <code>MultiLangUtils</code> 加载。当前语言缺键时静默回退
 * <code>zh-CN</code>；中文亦无则返回 <code>[N/A]</code>。
 * 需替换 <code>{name}</code> 时请用 <code>GetLang</code>。</p>
 *
 * @param tree 点分树形路径（如 <code>debug.trace.prefix</code>）。
 * @return 语言包中的原始字符串；两级皆无时为 <code>[N/A]</code>。
 * @example
 * <listing version="3.0">
 * GetLangText('debug.trace.prefix');
 * GetLangText('alert.musou_ctrl.need_more_money'); // 仍含 {amount} 原文
 * </listing>
 * @see GetLang
 * @see LANGUAGE
 * @see net.play5d.game.bvn.utils.MultiLangUtils
 */
public function GetLangText(tree:String):String {
    var langText:String = MultiLangUtils.I.getLangText(tree);
    return langText || '[N/A]';
}
}
