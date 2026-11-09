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
 * 按完整键取当前语言文案，并用命名占位符格式化。
 *
 * <p>等价于 <code>Format(GetLangText(key), params)</code>。键与语言包扁平键一致。</p>
 *
 * @param key 语言包完整键，如 <code>musou.need_more_money</code>。
 * @param params 占位符名到替换值的映射；可为 <code>null</code>。
 * @return 格式化后的当前语言文本。
 * @throws ArgumentError 模板里的占位符在 <code>params</code> 中没有对应键时，由 <code>Format</code> 抛出。语言包缺键时返回 <code>[N/A]</code>，不抛错。
 * @example
 * <listing version="3.0">
 * GetLang('common.yes');
 * GetLang('musou.need_more_money', {amount: 100});
 * </listing>
 * @see GetLangText
 * @see Format
 * @see LANGUAGE
 */
public function GetLang(key:String, params:Object = null):String {
    return Format(GetLangText(key), params);
}
}
