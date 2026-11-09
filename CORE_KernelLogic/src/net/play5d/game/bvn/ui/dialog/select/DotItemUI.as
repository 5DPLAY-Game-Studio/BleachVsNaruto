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

package net.play5d.game.bvn.ui.dialog.select {
import flash.display.MovieClip;

import net.play5d.game.bvn.utils.ResUtils;

/**
 * 分页圆点。构造后停在第 2 帧，也就是未选中。选中改到第 1 帧。
 */
public class DotItemUI {

    /**
     * 创建圆点并停在未选中帧。
     */
    public function DotItemUI() {
        _ui               = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, '$dialog$MC_dot');
        _ui.mouseChildren = false;
        _ui.buttonMode    = true;
        _ui.gotoAndStop(2);
    }
    /**
     * 这个点代表的页。构造时是 0，要另外赋值。
     *
     * @default 0
     */
    public var page:int = 0;
    private var _ui:$dialog$MC_dot;

    /**
     * 圆点影片。
     *
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var clip:MovieClip = dot.getUI();
     * </listing>
     */
    public function getUI():MovieClip {
        return _ui;
    }

    /**
     * 选中或取消。选中停第 1 帧，取消停第 2 帧。
     *
     * @param v 是否选中。
     * @example
     * <listing version="3.0">
     * dot.focus(true);
     * </listing>
     */
    public function focus(v:Boolean):void {
        _ui.gotoAndStop(v ? 1 : 2);
    }
}
}
