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

package net.play5d.game.bvn.ui {
import flash.filters.DropShadowFilter;

import net.play5d.kyo.display.BitmapText;

/**
 * 带阴影的位图字。字体固定是 Arial。宽高读的是内部文本框，不是排版后的像素边界。
 */
public class Text extends BitmapText {

    /**
     * 白色、20 号是默认。阴影用一份默认投影。
     *
     * @param color 字色。默认白色。
     * @param size 字号。默认 20。
     */
    public function Text(color:uint = 0xffffff, size:int = 20) {
        super(true, color, [new DropShadowFilter()]);

        font     = 'Arial';
        fontSize = size;

    }

    /**
     * 文本框报告的文字宽度。
     *
     * @return 文字宽度。
     */
    public override function get textWidth():Number {
        return _tf.textWidth;
    }

    /**
     * 文本框报告的文字高度。
     *
     * @return 文字高度。
     */
    public override function get textHeight():Number {
        return _tf.textHeight;
    }


}
}
