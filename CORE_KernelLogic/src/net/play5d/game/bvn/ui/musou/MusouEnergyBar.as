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

package net.play5d.game.bvn.ui.musou {
import flash.display.DisplayObject;

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.energy.EnergyBarFill;
import net.play5d.game.bvn.ui.energy.EnergyBarLabel;

/**
 * 无双能量条。超载优先于低能量闪烁。比例低于 0.3 且没超载时闪。还没设角色就渲染会抛错。能量上限是 0 时比例变成 Infinity。
 */
public class MusouEnergyBar {

    /**
     * 用界面上的条和文字建能量显示。缺件时抛错。
     *
     * @param ui 能量条影片。
     * @throws TypeError 影片或子件缺失时。
     */
    public function MusouEnergyBar(ui:$musou$MC_energyBar) {
        _ui = ui;

        _bar = new EnergyBarFill(_ui.bar);
        _txt = new EnergyBarLabel(_ui.energy_txtmc);

    }
    private var _fighter:FighterMain;

    private var _bar:EnergyBarFill;
    private var _txt:EnergyBarLabel;

    private var _renderFlash:Boolean;
    private var _renderFlashInt:int;

    private var _ui:$musou$MC_energyBar;

    /**
     * 能量条影片。
     *
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = bar.ui;
     * </listing>
     */
    public function get ui():DisplayObject {
        return _ui;
    }

    /**
     * 忘掉角色。界面还留着，之后渲染会抛错。
     *
     * @example
     * <listing version="3.0">
     * bar.destroy();
     * </listing>
     */
    public function destroy():void {
        _fighter = null;
    }

    /**
     * 换角色。有数据时按作品类型改文字。数据为空则不改文字。
     *
     * @param v 角色。null 时下次渲染抛错。
     * @example
     * <listing version="3.0">
     * bar.setFighter(fighter);
     * </listing>
     */
    public function setFighter(v:FighterMain):void {
        _fighter = v;

        if (v.data) {
            _txt.setType(v.data.comicType);
        }
    }

    /**
     * 按能量刷新条和文字。没有角色时抛错。
     *
     * @throws TypeError 还没有角色时。
     * @example
     * <listing version="3.0">
     * bar.render();
     * </listing>
     */
    public function render():void {

        _bar.rate = _fighter.energy / _fighter.energyMax;

        if (_fighter.energyOverLoad) {
            _bar.overLoad();
            _txt.overLoad();
        }
        else {
            if (_bar.rate < 0.3) {
                _bar.flash();
                _txt.flash();
            }
            else {
                _bar.normal();
                _txt.normal();
            }
        }

        _bar.render();
        _txt.render();

    }

}
}
