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

package net.play5d.game.bvn.ui {
import flash.display.DisplayObject;

/**
 * 三段气槽的横向缩放。
 *
 * <p>不处理显隐。满槽、最大值影片由调用方自己开关。</p>
 *
 * @see #apply()
 */
public class QiBarScale {

    /**
     * 按 0–3 的气量设置三段气槽的 <code>scaleX</code>。
     *
     * <p>大于 2 时前两段为 1，第三段为超出 2 的部分。大于 1 时第一段为 1，第二段为超出 1 的部分。否则只缩放第一段。</p>
     *
     * @param bar1 第一段。
     * @param bar2 第二段。
     * @param bar3 第三段。
     * @param value 气量，通常为 0–3。
     * @example
     * <listing version="3.0">
     * QiBarScale.apply(bar1, bar2, bar3, 2.4);
     * </listing>
     */
    public static function apply(
            bar1 :DisplayObject,
            bar2 :DisplayObject,
            bar3 :DisplayObject,
            value:Number
    ):void {
        if (value > 2) {
            bar1.scaleX = bar2.scaleX = 1;
            bar3.scaleX = value - 2;
        }
        else if (value > 1) {
            bar1.scaleX = 1;
            bar2.scaleX = value - 1;
        }
        else {
            bar1.scaleX = value;
        }
    }

}
}
