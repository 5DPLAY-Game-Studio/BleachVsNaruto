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

package net.play5d.game.bvn.test {
import feathers.text.TextFormat;

/**
 * 调试窗 Feathers / Steel 亮暗主题色与文字格式。
 *
 * @example
 * <listing version="3.0">
 * stage.color = DebugThemeChrome.bgColor(true);
 * label.textFormat = DebugThemeChrome.textFormat(true, false, 11);
 * </listing>
 * @see #bgColor()
 * @see #textFormat()
 */
public class DebugThemeChrome {
    /** Steel 暗色底 */
    public static const BG_DARK:uint = 0x383838;
    /** Steel 亮色底 */
    public static const BG_LIGHT:uint = 0xf8f8f8;
    /** Steel 暗色主文字 */
    public static const TEXT_DARK:uint = 0xf1f1f1;
    /** Steel 亮色主文字 */
    public static const TEXT_LIGHT:uint = 0x1f1f1f;
    /** Steel 暗色次文字 */
    public static const TEXT_SECONDARY_DARK:uint = 0xafafaf;
    /** Steel 亮色次文字 */
    public static const TEXT_SECONDARY_LIGHT:uint = 0x6f6f6f;

    /**
     * 当前全局字体名；未就绪时回退 <code>_sans</code>。
     * @return 字体名。
     * @example
     * <listing version="3.0">
     * var f:String = DebugThemeChrome.fontName();
     * </listing>
     */
    public static function fontName():String {
        return (FONT && FONT.fontName) ? FONT.fontName : '_sans';
    }

    /**
     * 按亮暗模式取窗口底色。
     * @param darkMode 是否暗色。
     * @return 底色。
     * @example
     * <listing version="3.0">
     * var bg:uint = DebugThemeChrome.bgColor(true);
     * </listing>
     */
    public static function bgColor(darkMode:Boolean):uint {
        return darkMode ? BG_DARK : BG_LIGHT;
    }

    /**
     * 按亮暗模式取文字色。
     * @param darkMode 是否暗色。
     * @param secondary 是否次要文字。
     * @return 文字色。
     * @example
     * <listing version="3.0">
     * var c:uint = DebugThemeChrome.textColor(true, true);
     * </listing>
     */
    public static function textColor(darkMode:Boolean, secondary:Boolean = false):uint {
        if (darkMode) {
            return secondary ? TEXT_SECONDARY_DARK : TEXT_DARK;
        }

        return secondary ? TEXT_SECONDARY_LIGHT : TEXT_LIGHT;
    }

    /**
     * 生成与当前亮暗、全局 FONT 匹配的文字格式。
     * @param darkMode 是否暗色。
     * @param secondary 是否次要文字色。
     * @param size 字号。
     * @return 文本格式。
     * @example
     * <listing version="3.0">
     * label.textFormat = DebugThemeChrome.textFormat(true, false, 11);
     * </listing>
     */
    public static function textFormat(darkMode:Boolean, secondary:Boolean = false, size:Number = 11):TextFormat {
        var tf:TextFormat = new TextFormat();
        tf.font           = fontName();
        tf.size           = size;
        tf.color          = textColor(darkMode, secondary);

        return tf;
    }
}
}
