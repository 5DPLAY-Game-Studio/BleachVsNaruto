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
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class KyoUI {
    public static var stage:Sprite;
    public static var tween:Boolean = false;

    public static var btnSize:Point = new Point(50, 20);


//		public static function align():void{
//
//		}

    public static function alert(msg:String, width:Number = 200, height:Number = 100):void {
        var sp:Sprite     = newBox(width, height);
        var txt:TextField = newTxt(msg, width);
        sp.addChild(txt);
        stage.addChild(sp);

        var btn:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        btn.x                 = (
                                        width - btn.width
                                ) / 2;
        btn.y                 = height - btn.height - 10;
        btn.onClick(close);
        sp.addChild(btn);

        if (tween) {
            sp.alpha = 0;
            TweenLite.to(sp, .5, {alpha: 1});
        }

        function close(e:Event = null):void {
            if (tween) {
                TweenLite.to(sp, .5, {
                    alpha: 0, onComplete: function ():void {
                        stage.removeChild(sp);
                        sp = null;
                    }
                });
            }
            else {
                stage.removeChild(sp);
                sp = null;
            }
        }
    }

    public static function confrim(msg:String, ok:Function = null, no:Function = null, width:Number = 200,
                                   height:Number                                                    = 100
    ):void {
        var sp:Sprite     = newBox(width, height);
        var txt:TextField = newTxt(msg, width);
        sp.addChild(txt);
        stage.addChild(sp);

        var btny:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        btny.x                 = width - btny.width * 2 - 20;
        btny.y                 = height - btny.height - 10;
        btny.onClick(function ():void {
            if (ok != null) {
                ok();
            }
            close();
        });
        sp.addChild(btny);

        var btnn:KyoSimpButton = new KyoSimpButton('取消', btnSize.x, btnSize.y);
        btnn.x                 = width - btnn.width - 10;
        btnn.y                 = height - btnn.height - 10;
        btnn.onClick(function ():void {
            if (no != null) {
                no();
            }
            close();
        });
        sp.addChild(btnn);

        function close(e:Event = null):void {
            stage.removeChild(sp);
            sp = null;
        }
    }


    private static function newTxt(msg:String, width:Number):TextField {
        var tf:TextFormat     = new TextFormat();
        tf.align              = TextFormatAlign.CENTER;
        var txt:TextField     = new TextField();
        txt.defaultTextFormat = tf;
        txt.mouseEnabled      = false;
        txt.text              = msg;
        txt.width             = width;
        txt.height            = txt.textHeight + 5;
        txt.y                 = 10;

        return txt;
    }

    private static function newBox(width:Number, height:Number):Sprite {
        var bg:Sprite = new Sprite();
        bg.graphics.lineStyle(1, 0);
        bg.graphics.beginFill(0xffffff, 1);
        bg.graphics.drawRect(0, 0, width, height);
        bg.graphics.endFill();

        bg.x = (
                       stage.stage.stageWidth - width
               ) / 2;
        bg.y = (
                       stage.stage.stageHeight - height
               ) / 2;

        return bg;
    }


}
}
