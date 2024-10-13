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
import flash.display.Sprite;
import flash.geom.Point;

public class Box extends Sprite {
    public function Box(width:Number, height:Number, color:int = 0, alpha:Number = 1, orgin:Point = null) {
        super();
        graphics.beginFill(color, alpha);
        graphics.drawRect(
                orgin ? -orgin.x : 0,
                orgin ? -orgin.y : 0,
                width,
                height);
        graphics.endFill();
    }
}
}
