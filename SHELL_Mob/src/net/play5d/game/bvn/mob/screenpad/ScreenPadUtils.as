package net.play5d.game.bvn.mob.screenpad {
import flash.display.Bitmap;
import flash.geom.Point;
import flash.system.Capabilities;

import net.play5d.game.bvn.mob.GameInterfaceManager;

public class ScreenPadUtils {
    public static function getArrow(cls:Class, size:Point):ScreenPadArrow {
        var arrow:ScreenPadArrow = new ScreenPadArrow();
        var bp:Bitmap            = new cls();
//			bp.scaleX = bp.scaleY = scale;
        arrow.display            = bp;
        arrow.display.alpha      = GameInterfaceManager.config.screenPadConfig.joyAlpha;
        arrow.init(size);
        return arrow;
    }

    public static function getButton(cls:Class, size:Point):ScreenPadBtn {
        var btn:ScreenPadBtn = new ScreenPadBtn();
        var bp:Bitmap        = new cls();
//			bp.scaleX = bp.scaleY = scale;
        btn.display          = bp;
        btn.display.alpha    = GameInterfaceManager.config.screenPadConfig.joyAlpha;
        btn.init(size);
        return btn;
    }

    public static function getPointByCM(cmX:Number = 0, cmY:Number = 0):Point {

        var dpi:Number = Capabilities.screenDPI;

        var pixel:Point = new Point();
        pixel.x         = (
                                  cmX * dpi
                          ) / 2.54;
        pixel.y         = (
                                  cmY * dpi
                          ) / 2.54;

        return pixel;
    }

    public static function cm2pixel(cm:Number):Number {
        var dpi:Number = Capabilities.screenDPI;
        return (
                       cm * dpi
               ) / 2.54;
    }

//		public static var scale:Number = 1;
    public function ScreenPadUtils() {
    }


}
}
