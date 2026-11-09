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

/**
 * 打开游戏相关网页。
 *
 * <p>默认在地址后追加 <code>MARK</code> 查询参数。</p>
 *
 * @see #go()
 * @see #WEBSITE
 */
public class URL {
    /**
     * 追加到链接上的来源标记。
     *
     * @default bvn
     */
    public static var MARK:String = 'bvn';

    /**
     * 游戏官方网站。
     *
     * @default http://www.1212321.com/index/
     */
    public static const WEBSITE:String          = 'http://www.1212321.com/index/';

    /**
     * 游戏官方论坛。
     *
     * @default http://bbs.1212321.com/
     */
    public static const BBS:String              = 'http://bbs.1212321.com/';

    /**
     * 下载游戏页面。
     *
     * @default http://www.1212321.com/index/
     */
    public static const DOWNLOAD:String         = 'http://www.1212321.com/index/';

    /**
     * 安卓端下载页面。
     *
     * @default http://1212321.com/index/game/phone/a48b52f9-6b6a-4448-91d2-d666ff93edd7
     */
    public static const DOWNLOAD_ANDROID:String = 'http://1212321.com/index/game/phone/a48b52f9-6b6a-4448-91d2-d666ff93edd7';

    /**
     * GitHub 仓库首页。
     *
     * @default https://github.com/5DPLAY-Game-Studio/BleachVsNaruto
     */
    public static const GITHUB:String           = 'https://github.com/5DPLAY-Game-Studio/BleachVsNaruto';

    /**
     * 在浏览器中打开链接。
     *
     * @param url 目标地址。
     * @param isAddMark 为 <code>true</code> 时追加 <code>MARK</code>，默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * URL.go(URL.WEBSITE);
     * </listing>
     * @see #markURL()
     */
    public static function go(url:String, isAddMark:Boolean = true):void {
        if (isAddMark) {
            var newurl:String = markURL(url);
            WebUtils.getURL(newurl);
        }
        else {
            WebUtils.getURL(url);
        }
    }

    /**
     * 在地址后追加来源标记。
     *
     * <p>已有查询串时用 <code>&amp;</code>，否则用 <code>?</code>。</p>
     *
     * @param url 原始地址。
     * @return 带 <code>MARK</code> 的地址。
     * @example
     * <listing version="3.0">
     * URL.markURL('http://www.1212321.com/index/');
     * </listing>
     * @see #MARK
     */
    public static function markURL(url:String):String {
        var addMark:String = url.indexOf('?') == -1 ? '?' : '&';
        var newurl:String  = url + addMark + MARK;
        return newurl;
    }

    /**
     * 打开官方网站。
     *
     * @param params 忽略的额外参数，便于直接当作鼠标回调。
     * @example
     * <listing version="3.0">
     * URL.website();
     * </listing>
     * @see #WEBSITE
     */
    public static function website(...params):void {
        go(WEBSITE);
    }

    /**
     * 打开手柄介绍帖，不追加来源标记。
     *
     * @param params 忽略的额外参数，便于直接当作鼠标回调。
     * @example
     * <listing version="3.0">
     * URL.buyJoystick();
     * </listing>
     */
    public static function buyJoystick(...params):void {
        go('http://bbs.1212321.com/forum.php?mod=viewthread&tid=110', false);
    }

    /**
     * 打开官方论坛。
     *
     * @param params 忽略的额外参数，便于直接当作鼠标回调。
     * @example
     * <listing version="3.0">
     * URL.bbs();
     * </listing>
     * @see #BBS
     */
    public static function bbs(...params):void {
        go(BBS);
    }

    /**
     * 打开 Patreon 支持页，不追加来源标记。
     *
     * @param params 忽略的额外参数，便于直接当作鼠标回调。
     * @example
     * <listing version="3.0">
     * URL.supportUS();
     * </listing>
     */
    public static function supportUS(...params):void {
        go('https://www.patreon.com/bleachvsnaruto', false);
    }

    /**
     * 打开下载页，不追加来源标记。
     *
     * @example
     * <listing version="3.0">
     * URL.download();
     * </listing>
     * @see #DOWNLOAD
     */
    public static function download():void {
        go(DOWNLOAD, false);
    }

    /**
     * 打开安卓端下载页。
     *
     * @param params 忽略的额外参数，便于直接当作鼠标回调。
     * @example
     * <listing version="3.0">
     * URL.downloadAndroid();
     * </listing>
     * @see #DOWNLOAD_ANDROID
     */
    public static function downloadAndroid(...params):void {
        go(DOWNLOAD_ANDROID);
    }

}
}
