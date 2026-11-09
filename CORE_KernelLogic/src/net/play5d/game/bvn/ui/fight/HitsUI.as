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

package net.play5d.game.bvn.ui.fight {
import flash.display.MovieClip;
import flash.geom.Point;

import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.MCNumber;

/**
 * 连击数字。已经显示时再 <code>show</code> 播 <code>update</code>，否则播 <code>fadein</code>。名字是 <code>hits1</code> 时会按数字宽度改影片横坐标。没显示时 <code>hide</code> 直接返回。
 */
public class HitsUI {

    /**
     * 在影片的 <code>ct</code> 上放连击数字。
     *
     * @param mc 连击影片。null 时抛错。
     * @throws TypeError 影片缺失时。
     */
    public function HitsUI(mc:MovieClip) {
        _mc           = mc;
        var cls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight, '$fight$MC_hitsNumer');
        _txtmc        = new MCNumber(cls, 0, 1, 35);
        _orgPos       = new Point(mc.x, mc.y);
        _mc.ct.addChild(_txtmc);
    }
    private var _mc:MovieClip;
    private var _txtmc:MCNumber;
    private var _isShow:Boolean;
    private var _orgPos:Point;

    /**
     * 摘掉数字。移除失败只吞掉。
     *
     * @example
     * <listing version="3.0">
     * hits.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_txtmc) {
            try {
                _mc.ct.removeChild(_txtmc);
            }
            catch (e:Error) {
            }
            _txtmc = null;
        }

        if (_mc) {
            _mc = null;
        }

        _orgPos = null;
    }

    /**
     * 显示连击数。已经显示时播更新，否则播进入。
     *
     * @param num 连击数。
     * @throws TypeError 已经销毁时。
     * @example
     * <listing version="3.0">
     * hits.show(8);
     * </listing>
     */
    public function show(num:int):void {
        _txtmc.number = num;

        var xoffset:Number = -_txtmc.width + 45;
        _txtmc.x           = xoffset;

        if (_mc.name == 'hits1') {
            _mc.x = _orgPos.x - xoffset;
        }

        if (_isShow) {
            _mc.gotoAndPlay('update');
            return;
        }
        _isShow = true;
        _mc.gotoAndPlay('fadein');
    }

    /**
     * 播放退出。当前没显示时直接返回。
     *
     * @example
     * <listing version="3.0">
     * hits.hide();
     * </listing>
     */
    public function hide():void {
        if (!_isShow) {
            return;
        }
        _isShow = false;
        _mc.gotoAndPlay('fadeout');
    }


}
}
