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

package net.play5d.kyo.loader {
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

public class LoaderBar extends Sprite {
    public function LoaderBar(width:Number = 500, height:Number = 10) {
        super();
        size = new Point(width, height);

        initlize();
    }

    public var color:uint     = 0xff0000;
    public var lineColor:uint = 0x426F00;
    public var thinkness:uint = 2;
    public var backColor:uint = 0;
    public var size:Point;
    private var _bar:Shape;

    public function initlize():void {
        graphics.clear();
        graphics.lineStyle(thinkness, lineColor);
        graphics.beginFill(backColor, 1);
        graphics.drawRect(0, -1, size.x, size.y + 1);
        graphics.endFill();

        _bar ||= new Shape();
        _bar.graphics.clear();
        _bar.graphics.beginFill(color, 1);
        _bar.graphics.drawRect(0, 0, size.x, size.y);
        _bar.graphics.endFill();

        addChild(_bar);
    }

    public function update(p:Number):void {
        _bar.scaleX = p;
    }

}
}
