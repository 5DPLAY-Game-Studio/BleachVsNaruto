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

package net.play5d.game.bvn.utils {
import flash.display.Bitmap;

public class EmbedAssetUtils {

    [Embed(source='/../assets/alipay.png')]
    private static var alipayPNG:Class;

    [Embed(source='/../assets/weixin.png')]
    private static var weixinPNG:Class;

    [Embed(source='/../assets/patreon.png')]
    private static var patreonPNG:Class;

    [Embed(source='/../assets/android.png')]
    private static var androidPNG:Class;


    private static var _alipay:Bitmap;
    private static var _weixin:Bitmap;
    private static var _patreon:Bitmap;
    private static var _android:Bitmap;

    public static function getAndroid():Bitmap {
        if (!_android) {
            _android           = new androidPNG();
            _android.smoothing = true;
        }
        return _android;
    }

    public static function getAlipay():Bitmap {
        if (!_alipay) {
            _alipay           = new alipayPNG();
            _alipay.smoothing = true;
        }
        return _alipay;
    }

    public static function getWeixin():Bitmap {
        if (!_weixin) {
            _weixin           = new weixinPNG();
            _weixin.smoothing = true;
        }
        return _weixin;
    }

    public static function getPatreon():Bitmap {
        if (!_patreon) {
            _patreon           = new patreonPNG();
            _patreon.smoothing = true;
        }
        return _patreon;
    }

    public function EmbedAssetUtils() {
    }

}
}
