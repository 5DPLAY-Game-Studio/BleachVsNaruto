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
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class KyoSimpButton extends Sprite {
    public function KyoSimpButton(label:String, width:Number = 50, height:Number = 20) {
        super();

        btnWidth  = width;
        btnHeight = height;

        drawBg([0xffffff, 0xcccccc]);

        var txt:TextField     = new TextField();
        var tf:TextFormat     = new TextFormat();
        tf.align              = TextFormatAlign.CENTER;
        tf.size               = 12;
        txt.defaultTextFormat = tf;

        txt.text   = label;
        txt.width  = width;
        txt.height = txt.textHeight + 5;

        txt.y = (
                        height - txt.height
                ) / 2;

        addChild(txt);

        buttonMode    = true;
        mouseChildren = false;

        addEventListener(MouseEvent.MOUSE_OVER, overHandler);
        addEventListener(MouseEvent.MOUSE_OUT, overHandler);
    }
    public var btnWidth:Number;
    public var btnHeight:Number;

    public function onClick(fun:Function):void {
        addEventListener(MouseEvent.CLICK, fun);
    }

    private function drawBg(color:Array):void {
        graphics.lineStyle(1, 0x666666);
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(btnWidth, btnHeight, 180 * 180 / 3.14, 0, 0);
        graphics.beginGradientFill(GradientType.LINEAR, color, [1, 1], [0, 255], mtx);
        graphics.drawRect(0, 0, btnWidth, btnHeight);
        graphics.endFill();
    }

    private function overHandler(e:MouseEvent):void {
        if (e.type == MouseEvent.MOUSE_OVER) {
            drawBg([0xffffff, 0xF2F2F2]);
        }
        else {
            drawBg([0xffffff, 0xcccccc]);
        }
    }

}
}
