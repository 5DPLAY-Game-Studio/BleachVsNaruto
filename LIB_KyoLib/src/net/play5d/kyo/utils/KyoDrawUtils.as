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
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;

public class KyoDrawUtils {
    private static var _drawShape:Shape;

    public static function drawRing(
            width:Number, radius:Number, angle:int, color:Object = 0xffff00, alpha:Number = 1):BitmapData {

        var bd:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);

        if (!_drawShape) {
            _drawShape = new Shape();
        }
        drawSector(_drawShape.graphics, radius, radius, radius, angle, -90, color, alpha);
        bd.draw(_drawShape);
        _drawShape.graphics.clear();

        _drawShape.graphics.beginFill(0xff0000, 1);
        _drawShape.graphics.drawCircle(radius, radius, radius - width);
        _drawShape.graphics.endFill();

        bd.draw(_drawShape, null, null, BlendMode.ERASE);
        _drawShape.graphics.clear();

        return bd;
    }

    public static function drawSector(
            graphics:Graphics, x:Number = 200, y:Number = 200, r:Number = 100, angle:Number = 60, startFrom:Number = 0,
            color:Object                                                                                           = 0xFFFFFF, alpha:Number                                                                  = 1
    ):void {
        graphics.clear();
        if (color is Array) {
            var alphaArr:Array = [];
            for (var j:int; j < color.length; j++) {
                alphaArr.push(alpha);
            }
            graphics.beginGradientFill(GradientType.LINEAR, color as Array, alphaArr, [128, 255]);
        }
        else {
            graphics.beginFill(color as uint, alpha);
        }
//			graphics.lineStyle(0,color);
//			graphics.lineTo(x,y);

        angle = (
                        Math.abs(angle) > 360
                ) ? 360 : angle;

        var n:int         = Math.ceil(Math.abs(angle) / 45);
        var angleA:Number = angle / n;

        angleA    = angleA * Math.PI / 180;
        startFrom = startFrom * Math.PI / 180;

        graphics.moveTo(x + r * Math.cos(startFrom), y + r * Math.sin(startFrom));

        var i:int;
        var angleMid:Number, bx:Number, by:Number, cx:Number, cy:Number;

        for (i = 1; i <= n; i++) {
            startFrom += angleA;
            angleMid = startFrom - angleA / 2;
            bx       = x + r / Math.cos(angleA / 2) * Math.cos(angleMid);
            by       = y + r / Math.cos(angleA / 2) * Math.sin(angleMid);
            cx       = x + r * Math.cos(startFrom);
            cy       = y + r * Math.sin(startFrom);
            graphics.curveTo(bx, by, cx, cy);
        }

        if (angle != 360) {
            graphics.lineTo(x, y);
        }
        graphics.endFill();
    }

    public function KyoDrawUtils() {
    }

}
}
