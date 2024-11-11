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

package net.play5d.kyo.display {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;

public class BitmapOutput extends Bitmap {
    public function BitmapOutput(
            source:DisplayObject, width:int, height:int, transparent:Boolean = false, fillColor:int = 0,
            pixelSnapping:String                                                                    = 'auto', smoothing:Boolean                                        = false
    ) {
        super(null, pixelSnapping, smoothing);
        _source      = source;
        _width       = width;
        _height      = height;
        _transparent = transparent;
        _fillColor   = fillColor;
    }

    private var _source:DisplayObject;
    private var _width:int;
    private var _height:int;
    private var _transparent:Boolean;
    private var _fillColor:int;

    public function render():void {
        bitmapData   = new BitmapData(_width, _height, _transparent, _fillColor);
        var m:Matrix = new Matrix(_source.scaleX, 0, 0, _source.scaleY);
        bitmapData.draw(_source, m);
    }

    public function destory():void {
        _source = null;
        bitmapData.dispose();
        bitmapData = null;
    }
}
}
