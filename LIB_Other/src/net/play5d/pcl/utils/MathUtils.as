/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.pcl.utils {

/**
 * 数学工具类
 */
public class MathUtils {

    // 最大罗马数字
    public static const MAX_ROMAN:int = 3999;
    // 最小罗马数字
    public static const MIN_ROMAN:int = 1;

    /**
     * 整型转罗马数字
     *
     * @param number 需要转换的数字，范围在 [1, 3999] 之间
     * @return 罗马数字字符串
     */
    public static function int2roman(number:int):String {
        // 罗马数字数组
        const ROMAN_NUMS:Array = [
            // 1 - 9
            ['', 'Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ', 'Ⅴ', 'Ⅵ', 'Ⅶ', 'Ⅷ', 'Ⅸ'],
            // 10 - 90
            ['', 'Ⅹ', 'ⅩⅩ', 'ⅩⅩⅩ', 'ⅩⅬ', 'Ⅼ', 'ⅬⅩ', 'ⅬⅩⅩ', 'ⅬⅩⅩⅩ', 'ⅩⅭ'],
            // 100 - 900
            ['', 'Ⅽ', 'ⅭⅭ', 'ⅭⅭⅭ', 'ⅭⅮ', 'Ⅾ', 'ⅮⅭ', 'ⅮⅭⅭ', 'ⅮⅭⅭⅭ', 'ⅭⅯ'],
            // 1000 - 3000
            ['', 'Ⅿ', 'ⅯⅯ', 'ⅯⅯⅯ']
        ];

        // 检查范围
        if (number < MIN_ROMAN || number > MAX_ROMAN) {
            return null;
        }

        // 罗马数字字符串
        var roman:String = "";
        for (var i:int = 0; number > 0; i++) {
            roman = ROMAN_NUMS[i][number % 10] + roman;
            number = Math.floor(number / 10);
        }

        return roman;
    }
}
}
