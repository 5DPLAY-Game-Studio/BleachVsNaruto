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

package net.play5d.kyo.display.shapes {
import flash.display.Shape;

public class Line extends Shape {
    public function Line(width:Number, thinkness:Number = 1, color:int = 0, angel:int = 0) {
        super();
        graphics.beginFill(color, 1);
        graphics.drawRect(0, 0, width, thinkness);
        graphics.endFill();
        this.rotation = angel;
    }
}
}
