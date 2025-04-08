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
import net.play5d.kyo.utils.WebUtils;

public class URL {
    // 链接标记
    public static var MARK:String = "bvn";

    // 游戏官方网站链接
    public static const WEBSITE:String          = "http://www.1212321.com/index/";
    // 游戏官方论坛链接
    public static const BBS:String              = "http://bbs.1212321.com/";
    // 下载游戏链接
    public static const DOWNLOAD:String         = "http://www.1212321.com/index/";
    // 下载安卓端游戏链接
    public static const DOWNLOAD_ANDROID:String = "http://1212321.com/index/game/phone/a48b52f9-6b6a-4448-91d2-d666ff93edd7";
    // GitHub发布页面链接
    public static const GITHUB:String           = "https://github.com/5DPLAY-Game-Studio/BleachVsNaruto";


    public static function go(url:String, isAddMark:Boolean = true):void {
        if (isAddMark) {
            var newurl:String = markURL(url);
            WebUtils.getURL(newurl);
        }
        else {
            WebUtils.getURL(url);
        }
    }

    public static function markURL(url:String):String {
        var addMark:String = url.indexOf('?') == -1 ? '?' : '&';
        var newurl:String  = url + addMark + MARK;
        return newurl;
    }

    public static function website(...params):void {
        go(WEBSITE);
    }

    public static function buyJoystick(...params):void {
        go('http://bbs.1212321.com/forum.php?mod=viewthread&tid=110', false);
    }

    public static function bbs(...params):void {
        go(BBS);
    }

    public static function supportUS(...params):void {
        go('https://www.patreon.com/bleachvsnaruto', false);
    }

    public static function download():void {
        go(DOWNLOAD, false);
    }

    public static function download_android(...params):void {
        go(DOWNLOAD_ANDROID);
    }

    public function URL() {
    }

}
}
