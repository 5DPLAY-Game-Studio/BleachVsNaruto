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

package net.play5d.game.bvn.ide.utils {

/**
 * 颜色相关实用工具
 */
public class ColorUtils {

    /**
     * 十进制转十六进制
     * @param color 颜色十进制数值
     * @return 颜色十六进制数值
     */
    public static function dec2hex(color:uint):String {
        var colArr:Array = color.toString(16).toUpperCase().split('');
        var diff:int     = 6 - colArr.length;

        for (var i:int = 0; i < diff; i++) {
            colArr.unshift('0');
        }

        return '#' + colArr.join('');
    }
}
}
