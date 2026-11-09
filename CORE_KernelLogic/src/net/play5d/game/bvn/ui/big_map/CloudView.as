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

package net.play5d.game.bvn.ui.big_map {
import flash.display.MovieClip;

import net.play5d.game.bvn.utils.ResUtils;

/**
 * 一张往上飘的云。透明度在 0.2 到 0.5 之间，速度在 0.02 到 0.12 之间，帧停在随机一帧。
 */
public class CloudView {

    /**
     * 创建云并放到给定坐标。
     *
     * @param X 横坐标。
     * @param Y 纵坐标。
     */
    public function CloudView(X:Number, Y:Number) {
        mc       = ResUtils.I.createDisplayObject(ResUtils.swfLib.big_map, '$big_map$MC_cloud');
        mc.x     = X;
        mc.y     = Y;
        mc.alpha = 0.2 + Math.random() * 0.3;
        mc.gotoAndStop(1 + int(Math.random() * mc.totalFrames));
        speed = 0.02 + Math.random() * 0.1;

    }
    /**
     * 向上的速度。构造后会被随机值盖掉。
     *
     * @default 0
     */
    public var speed:Number = 0;
    /**
     * 云影片。
     */
    public var mc:MovieClip;

    /**
     * 按速度上移。
     *
     * @return 云顶已经高过画面 30 像素时为 true。
     * @example
     * <listing version="3.0">
     * var gone:Boolean = cloud.render();
     * </listing>
     */
    public function render():Boolean {
        mc.y -= speed;
        return mc.y < -mc.height + 30;
    }

}
}
