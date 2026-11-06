package net.play5d.game.bvn.mob.screenpad {
import flash.display.Bitmap;
import flash.geom.Point;

import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.utils.UiBitmap;

import net.play5d.kyo.utils.KyoDisplayUtils;
/**
 * 屏幕虚拟手柄工厂（箭头 / 按钮）。
 *
 * <p>厘米像素换算请用 <code>KyoDisplayUtils.cm2pixel</code>。</p>
 */
public class ScreenPadUtils {
    public static function getArrow(name:String, size:Point):ScreenPadArrow {
        var arrow:ScreenPadArrow = new ScreenPadArrow();
        var bp:Bitmap            = UiBitmap.create(name);
        arrow.display            = bp;
        arrow.display.alpha      = GameInterfaceManager.config.screenPadConfig.joyAlpha;
        arrow.init(size);
        return arrow;
    }

    public static function getButton(name:String, size:Point):ScreenPadBtn {
        var btn:ScreenPadBtn = new ScreenPadBtn();
        var bp:Bitmap        = UiBitmap.create(name);
        btn.display          = bp;
        btn.display.alpha    = GameInterfaceManager.config.screenPadConfig.joyAlpha;
        btn.init(size);
        return btn;
    }

}
}
