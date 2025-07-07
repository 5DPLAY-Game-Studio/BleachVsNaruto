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
 * 颜色实用工具类
 */
public class ColorUtils {

    // 黑
    public static const BLACK:uint = 0x000000;
    // 白
    public static const WHITE:uint = 0xFFFFFF;

    // 红
    public static const RED:uint = 0xFF0000;
    // 绿
    public static const GREEN:uint = 0x00FF00;
    // 蓝
    public static const BLUE:uint = 0x0000FF;

    // 黄
    public static const YELLOW:uint = RED | GREEN;
    // 粉
    public static const PINK:uint = RED | BLUE;
    // 青
    public static const CYAN:uint = GREEN | BLUE;

}
}
