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

package net.play5d.kyo.display.ui {
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

public class KyoMouseOverEffect {
    public static const EFFECT_TYPE_HILIGHT:int = 0;

    public static function addEffect(display:DisplayObject, effectType:int = 0,
                                     targetDisplay:DisplayObject = null):void {
        targetDisplay ||= display;

        function doEffect(over:Boolean):void {
            switch (effectType) {
            case EFFECT_TYPE_HILIGHT:
                if (over) {
                    var ct:ColorTransform                  = new ColorTransform();
                    ct.redOffset                           = ct.greenOffset = ct.blueOffset = 128;
                    targetDisplay.transform.colorTransform = ct;
                }
                else {
                    targetDisplay.transform.colorTransform = new ColorTransform();
                }
                break;
            }
        }

        display.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void {
            doEffect(true);
        });
        display.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void {
            doEffect(false);
        });
    }

    public function KyoMouseOverEffect() {
    }

}
}
