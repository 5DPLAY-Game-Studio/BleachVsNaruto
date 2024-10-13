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
import flash.geom.Point;

public class KyoAlign {
    public static function left(A:DisplayObject, B:DisplayObject):void {

    }

    public static function right(A:DisplayObject, B:DisplayObject):void {

    }

    public static function centerH(A:DisplayObject, B:Object):void {
        var Bnum:Number;
        if (B is Number) {
            Bnum = B as Number;
        }
        if (B is Point) {
            var bp:Point = B as Point;
            Bnum         = bp.y - bp.x;
        }
        if (B is DisplayObject) {
            A.y  = (
                    B as DisplayObject
            ).y;
            Bnum = (
                    B as DisplayObject
            ).height;
        }
        var diff:Number = Bnum - A.height;
        A.y += diff / 2;
    }

    public static function up(A:DisplayObject, B:DisplayObject):void {

    }

    public static function down(A:DisplayObject, B:DisplayObject):void {

    }

    public static function centerW(A:DisplayObject, B:Object):void {
        var Bnum:Number;
        if (B is Number) {
            Bnum = B as Number;
        }
        if (B is Point) {
            var bp:Point = B as Point;
            Bnum         = bp.y - bp.x;
        }
        if (B is DisplayObject) {
            A.x  = (
                    B as DisplayObject
            ).x;
            Bnum = (
                    B as DisplayObject
            ).width;
        }
        var diff:Number = Bnum - A.width;
        A.x += diff / 2;
    }

    public function KyoAlign() {
    }


}
}
