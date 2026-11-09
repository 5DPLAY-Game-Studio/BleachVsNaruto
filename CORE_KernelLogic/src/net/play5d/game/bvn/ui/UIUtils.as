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

package net.play5d.game.bvn.ui {
import flash.text.TextField;
import flash.text.TextFormat;

import net.play5d.kyo.utils.KyoUtils;

/**
 * 文本格式入口。
 *
 * <p>没传格式参数时不改字体，只在 <code>formatTextFunction</code> 有值时再交给它。<code>LOCK_FONT</code> 会盖掉参数里的字体。嵌入字体只在传了格式参数时打开。</p>
 */
public class UIUtils {

    /**
     * 额外的文本处理。null 时不调用。
     *
     * @default null
     */
    public static var formatTextFunction:Function;
    /**
     * 默认字体。锁定字体为空时使用它。
     *
     * @default 黑体
     */
    public static var DEFAULT_FONT:String = '黑体';
    /**
     * 强制字体。有值时盖掉格式参数里的字体。
     *
     * @default null
     */
    public static var LOCK_FONT:String    = null;

    /**
     * 按参数写默认格式。参数为空时跳过格式，仍可能调用 <code>formatTextFunction</code>。
     *
     * @param text 文本框。null 时抛错。
     * @param textFormatParam 写到 <code>TextFormat</code> 上的字段。默认 null。
     * @throws TypeError 文本框为 null 时。
     * @example
     * <listing version="3.0">
     * UIUtils.formatText(field, {size: 16});
     * </listing>
     */
    public static function formatText(text:TextField, textFormatParam:Object = null):void {
        if (textFormatParam) {
            var tf:TextFormat = new TextFormat();
            tf.font           = DEFAULT_FONT;
            KyoUtils.setValueByObject(tf, textFormatParam);
            if (LOCK_FONT) {
                tf.font = LOCK_FONT;
            }
            text.defaultTextFormat = tf;
            text.embedFonts        = true;

        }

        if (formatTextFunction != null) {
            formatTextFunction(text);
        }
    }

}
}
