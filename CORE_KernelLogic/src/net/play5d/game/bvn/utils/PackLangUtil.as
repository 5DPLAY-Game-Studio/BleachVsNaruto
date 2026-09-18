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

package net.play5d.game.bvn.utils {
import net.play5d.game.bvn.data.LanguageType;

/**
 * 角色/地图包 meta 展示字段的多语言解析。
 *
 * <p>标准形态：<code>language.{locale}.name</code> / <code>says</code>
 *（locale 如 <code>zh-CN</code>）。回退：当前 <code>LANGUAGE</code> →
 * <code>zh-CN</code> → 首个可用 locale 块。不走全局 <code>GetLang</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * var pack:Object = PackLangUtil.pickLocalePack(meta.language);
 * PackLangUtil.resolveString(pack.name.aizen, 'aizen');
 * </listing>
 */
public class PackLangUtil {

    /**
     * 从 <code>meta.language</code> 取出当前 locale 内容块。
     *
     * <p>兼容旧形态 <code>{ name, says }</code>（视为 <code>zh-CN</code>）。</p>
     *
     * @param languageRoot <code>meta.language</code> 对象。
     * @return 含 <code>name</code>/<code>says</code> 的对象；皆无则为 <code>null</code>。
     */
    public static function pickLocalePack(languageRoot:Object):Object {
        if (!languageRoot) {
            return null;
        }
        // 旧形态：language 下直接 name/says
        if (languageRoot['name'] != null || languageRoot['says'] != null) {
            return languageRoot;
        }

        var lang:String = LANGUAGE;
        if (lang && languageRoot[lang] != null) {
            return languageRoot[lang] as Object;
        }
        if (languageRoot[LanguageType.CHINESE_SIMPLIFIED] != null) {
            return languageRoot[LanguageType.CHINESE_SIMPLIFIED] as Object;
        }

        for (var k:String in languageRoot) {
            var block:Object = languageRoot[k] as Object;
            if (block) {
                return block;
            }
        }

        return null;
    }

    /**
     * 解析展示用字符串（如 <code>name</code>）。
     *
     * @param raw      字符串或 locale→字符串映射；可为 <code>null</code>。
     * @param fallback 皆无时的回退（如 variant <code>id</code>）。
     * @return 解析后的字符串；皆无则为 <code>fallback</code>。
     */
    public static function resolveString(raw:*, fallback:String = null):String {
        if (raw == null) {
            return fallback;
        }
        if (raw is String) {
            var s:String = raw as String;

            return s || fallback;
        }
        if (raw is Array) {
            return fallback;
        }

        var text:String = pickLocaleString(raw as Object);

        return text || fallback;
    }

    /**
     * 解析台词数组（如 <code>says</code>）。
     *
     * @param raw 字符串数组，或 locale→字符串数组映射；可为 <code>null</code>。
     * @return 解析后的数组；皆无则为 <code>null</code>。
     */
    public static function resolveStringArray(raw:*):Array {
        if (raw == null) {
            return null;
        }
        if (raw is Array) {
            return raw as Array;
        }

        return pickLocaleArray(raw as Object);
    }

    /**
     * @private 从 locale map 取字符串
     */
    private static function pickLocaleString(map:Object):String {
        if (!map) {
            return null;
        }

        var v:* = valueForLocale(map);
        if (v is String && String(v)) {
            return String(v);
        }

        for (var k:String in map) {
            v = map[k];
            if (v is String && String(v)) {
                return String(v);
            }
        }

        return null;
    }

    /**
     * @private 从 locale map 取字符串数组
     */
    private static function pickLocaleArray(map:Object):Array {
        if (!map) {
            return null;
        }

        var v:* = valueForLocale(map);
        if (v is Array) {
            return v as Array;
        }

        for (var k:String in map) {
            v = map[k];
            if (v is Array) {
                return v as Array;
            }
        }

        return null;
    }

    /**
     * @private 当前语言或 zh-CN 对应值（未校验类型）
     */
    private static function valueForLocale(map:Object):* {
        var lang:String = LANGUAGE;
        if (lang && map[lang] != null) {
            return map[lang];
        }

        return map[LanguageType.CHINESE_SIMPLIFIED];
    }

}
}
