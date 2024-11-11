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
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

public class BitmapText extends Bitmap {
    public function BitmapText(autoUpdate:Boolean = true, color:uint = 0, filers:Array = null) {
        this.autoUpdate = autoUpdate;
        this.smoothing  = true;

        _filers = filers;
        _tf     = new TextField();

        this.color = color;
    }

    public var autoUpdate:Boolean;
    protected var _tf:TextField;
    private var _format:TextFormat = new TextFormat();
    private var _filers:Array;

    private var _width:Number = 0;

    public override function set width(value:Number):void {
        _width    = value;
        _tf.width = value;
    }

    private var _height:Number = 0;

    public override function set height(value:Number):void {
        _height    = value;
        _tf.height = value;
    }

    public function get textfield():TextField {
        return _tf;
    }

    public function get font():String {
        return _format.font;
    }

    public function set font(v:String):void {
        _format.font = v;
        if (autoUpdate) {
            update();
        }
    }

    public function get fontSize():Object {
        return _format.size;
    }

    public function set fontSize(v:Object):void {
        _format.size = v;
        if (autoUpdate) {
            update();
        }
    }

    public function get color():uint {
        return _format.color as uint;
    }

    public function set color(value:uint):void {
        _format.color = value;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * TextFieldAutoSize
     */
    public function get align():String {
        return _format.align;
    }

    public function set align(value:String):void {
        _format.align = value;
    }

    public function get text():String {
        return _tf.text;
    }

    public function set text(value:String):void {
        _tf.text = value;
        if (autoUpdate) {
            update();
        }
    }

    public function get defaultTextFormat():TextFormat {
        return _format;
    }

    public function set defaultTextFormat(v:TextFormat):void {
        _format = v;
        if (autoUpdate) {
            update();
        }
    }

    public function get textWidth():Number {
        return _tf.width;
    }

    public function set textWidth(v:Number):void {
        _tf.width = v;
    }

    public function get textHeight():Number {
        return _tf.height;
    }

    public function set textHeight(v:Number):void {
        _tf.height = v;
    }

    public function set leading(v:Number):void {
        _format.leading = v;
    }

    public function set letterSpacing(v:Number):void {
        _format.letterSpacing = v;
    }

    public function multiLine(v:Boolean):void {
        _tf.multiline = v;
        _tf.wordWrap  = true;
    }

    public function setTextFormat(f:TextFormat, beginIndex:int = -1, endIndex:int = -1):void {
        _tf.setTextFormat(f, beginIndex, endIndex);
        if (autoUpdate) {
            update();
        }
    }

    public function getTextWidth():Number {
        return _tf.textWidth;
    }

    public function update():void {

        if (!_tf) {
            return;
        }
        if (!_tf.text) {
            return;
        }

        var size:int = int(_format.size) > 0 ? int(_format.size) : 12;

        _tf.setTextFormat(_format);

        _tf.width         = (
                                    _width != 0
                            ) ? _width : (
                                    _tf.textWidth + size
                            );
        _tf.height        = (
                                    _height != 0
                            ) ? _height : (
                                    _tf.textHeight + size
                            );
        var bd:BitmapData = new BitmapData(_tf.width, _tf.height, true, 0);

//			bd.fillRect(new Rectangle(0,0,bd.width,bd.height), 0xffffff);

        bd.draw(_tf);
        if (_filers) {
            for each(var i:BitmapFilter in _filers) {
                bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(), i);
            }
        }

        if (bitmapData) {
            bitmapData.dispose();
        }

        bitmapData = bd;
    }

    public function destory():void {
        try {
            parent.removeChild(this);
        }
        catch (e:Error) {
        }
        if (bitmapData) {
            bitmapData.dispose();
        }
        _tf = null;
    }

}
}
