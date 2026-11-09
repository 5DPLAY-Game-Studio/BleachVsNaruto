/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.utils {
import flash.display.Bitmap;

/**
 * 按文件名读取界面位图图标。
 *
 * <p>文件在 <code>assets/ui/bitmap</code>，读入后开启平滑。</p>
 *
 * @see UiBitmap
 */
public class EmbedAssetUtils {

    /**
     * 读取 Android 图标。
     *
     * @param back 成功回调，参数为位图。
     * @example
     * <listing version="3.0">
     * EmbedAssetUtils.getAndroid(onIcon);
     * </listing>
     */
    public static function getAndroid(back:Function):void {
        load('android.png', back);
    }

    /**
     * 读取支付宝图标。
     *
     * @param back 成功回调，参数为位图。
     * @example
     * <listing version="3.0">
     * EmbedAssetUtils.getAlipay(onIcon);
     * </listing>
     */
    public static function getAlipay(back:Function):void {
        load('alipay.png', back);
    }

    /**
     * 读取微信图标。
     *
     * @param back 成功回调，参数为位图。
     * @example
     * <listing version="3.0">
     * EmbedAssetUtils.getWeixin(onIcon);
     * </listing>
     */
    public static function getWeixin(back:Function):void {
        load('weixin.png', back);
    }

    /**
     * 读取 Patreon 图标。
     *
     * @param back 成功回调，参数为位图。
     * @example
     * <listing version="3.0">
     * EmbedAssetUtils.getPatreon(onIcon);
     * </listing>
     */
    public static function getPatreon(back:Function):void {
        load('patreon.png', back);
    }

    /** @private 读取位图并开启平滑后回调 */
    private static function load(name:String, back:Function):void {
        UiBitmap.load(name, function (bmp:Bitmap):void {
            bmp.smoothing = true;
            back(bmp);
        });
    }

}
}
