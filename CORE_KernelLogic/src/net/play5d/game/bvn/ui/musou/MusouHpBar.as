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
import net.play5d.game.bvn.ui.HpBarLerp;

/**
 * 无双血条。还没 <code>setFighter</code> 就渲染会抛错。
 */
public class MusouHpBar {

    /**
     * 用两条显示对象做血条缓动。
     *
     * @param bar 当前血条。
     * @param bar2 滞后的红条。
     */
    public function MusouHpBar(bar:DisplayObject, bar2:DisplayObject) {
        _lerp = new HpBarLerp(bar, bar2);
    }
    private var _fighter:FighterMain;
    private var _lerp:HpBarLerp;

    /**
     * 记下要显示的角色。传 null 时，下次渲染会抛错。
     *
     * @param fighter 角色。
     * @example
     * <listing version="3.0">
     * bar.setFighter(fighter);
     * </listing>
     */
    public function setFighter(fighter:FighterMain):void {
        _fighter = fighter;
    }

    /**
     * 按角色血量推进血条。角色为 null 时抛错。
     *
     * @throws TypeError 还没有角色时。
     * @example
     * <listing version="3.0">
     * bar.render();
     * </listing>
     */
    public function render():void {
        _lerp.render(_fighter);
    }

}
}
