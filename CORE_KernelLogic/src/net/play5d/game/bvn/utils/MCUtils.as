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
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.kyo.utils.KyoDisplayUtils;

/**
 * 影片剪辑通用工具（委托 <code>KyoDisplayUtils</code>）。
 *
 * <p>对局 Sprite 染色 / 遍历见 <code>GameSpriteUtil</code>。</p>
 *
 * @see net.play5d.kyo.utils.KyoDisplayUtils#hasFrameLabel()
 * @see net.play5d.kyo.utils.KyoDisplayUtils#setHue()
 * @see net.play5d.kyo.utils.KyoDisplayUtils#stopAllMovieClips()
 * @see net.play5d.game.bvn.ctrler.game_ctrls.GameSpriteUtil
 */
public class MCUtils {

    /**
     * 影片剪辑是否具有指定名称帧。
     *
     * @param mc 指定影片剪辑
     * @param label 帧名称
     *
     * @return 影片剪辑是否具有某个帧
     * @see net.play5d.kyo.utils.KyoDisplayUtils#hasFrameLabel()
     */
    public static function hasFrameLabel(mc:MovieClip, label:String):Boolean {
        return KyoDisplayUtils.hasFrameLabel(mc, label);
    }

    /**
     * 设置显示对象色相滤镜（-180 - 180）
     *
     * @param display
     * @param hue 色相值（-180 - 180）
     * @see net.play5d.kyo.utils.KyoDisplayUtils#setHue()
     */
    public static function setHue(display:DisplayObject, hue:Number = 0):void {
        KyoDisplayUtils.setHue(display, hue);
    }

    /**
     * 停止指定影片剪辑以及其子影片剪辑的播放
     *
     * @param mc 指定影片剪辑
     * @see net.play5d.kyo.utils.KyoDisplayUtils#stopAllMovieClips()
     */
    public static function stopAllMovieClips(mc:MovieClip):void {
        KyoDisplayUtils.stopAllMovieClips(mc);
    }

}
