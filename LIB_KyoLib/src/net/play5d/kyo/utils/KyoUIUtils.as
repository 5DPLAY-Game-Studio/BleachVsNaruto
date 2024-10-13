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

package net.play5d.kyo.utils {
import flash.display.DisplayObject;
import flash.text.TextFormat;

public class KyoUIUtils {
    public static function setBarScaleX(ui:DisplayObject, per:Number):void {
        if (per > 0) {
            ui.scaleX  = per;
            ui.visible = true;
        }
        else {
            ui.visible = false;
        }
    }

    /**
     * 设置FLASH的UI组件字体
     * @param ui
     * @param font 对应TextFormat的值，默认为宋体，12号
     */
    public static function setFlashUIFont(ui:*, font:Object = null):void {
        var tft:TextFormat = new TextFormat();
        tft.font           = '宋体';
        tft.size           = 12;
        if (font) {
            KyoUtils.setValueByObject(tft, font);
        }

        try {
            ui.setStyle('textFormat', tft);
            ui.textField.setStyle('textFormat', tft);
            ui.dropdown.setRendererStyle('textFormat', tft);
        }
        catch (e:Error) {
        }
    }
}
}
