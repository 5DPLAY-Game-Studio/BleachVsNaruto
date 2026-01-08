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

package net.play5d.game.bvn.data {

/**
 * 语言类型
 */
public class LanguageType {
    include '../../../../../../include/ImportVersion.as';

    // 简体中文
    public static const CHINESE_SIMPLIFIED:String  = 'zh-CN';
    // 繁体中文
    public static const CHINESE_TRADITIONAL:String = 'zh-TW';
    // 英文
    public static const ENGLISH:String             = 'en';
    // 日文
    public static const JAPANESE:String            = 'ja';
    // 韩文
    public static const KOREAN:String              = 'ko';
    // 越南语
    public static const VIETNAMESE:String          = 'vi';

    // 所有语言
    [ArrayElementType('String')]
    private static const _languages:Array          = [
        CHINESE_SIMPLIFIED, CHINESE_TRADITIONAL,
        ENGLISH,
        JAPANESE,
        KOREAN,
        VIETNAMESE
    ];

    /**
     * 是否支持当前语言
     * @param language 语言
     * @return 是否支持当前语言
     */
    public static function isSupported(language:String):Boolean {
        return _languages.indexOf(language) != -1;
    }

    /**
     * 是否为简体中文
     * @return 是否为简体中文
     */
    public static function isSimplifiedChinese(language:String):Boolean {
        return language == CHINESE_SIMPLIFIED;
    }
}
}
