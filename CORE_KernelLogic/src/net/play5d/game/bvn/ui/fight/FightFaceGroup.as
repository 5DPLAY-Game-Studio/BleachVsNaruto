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
import flash.display.DisplayObject;

import net.play5d.game.bvn.data.GameRunFighterGroup;

/**
 * 一组三个头像。没有当前角色时会先关掉位图缓存，然后直接返回，缓存不会重新打开。当前数据对不上三个槽时，后两个头像保持原样。
 */
public class FightFaceGroup {

    /**
     * 用界面上的三张脸建头像。缺脸时抛错。
     *
     * @param ui 头像组影片。
     * @throws TypeError 影片或其中一张脸缺失时。
     */
    public function FightFaceGroup(ui:$fight$MC_hpBarFaceGroup) {
        _ui = ui;

        _ui.cacheAsBitmap = true;

        _face1 = new FightFaceUI(_ui.face);
        _face2 = new FightFaceUI(_ui.face2);
        _face3 = new FightFaceUI(_ui.face3);
    }
    private var _face1:FightFaceUI;
    private var _face2:FightFaceUI;
    private var _face3:FightFaceUI;

    private var _ui:$fight$MC_hpBarFaceGroup;

    /**
     * 头像组影片。
     *
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = faces.ui;
     * </listing>
     */
    public function get ui():DisplayObject {
        return _ui;
    }

    /**
     * 按当前出战角色重排三张脸。组为 null 时抛错。没有当前角色时直接返回，后两张不更新。
     *
     * @param fighterGroup 角色组。默认 null，传 null 会抛错。
     * @throws TypeError 组为 null 时。
     * @example
     * <listing version="3.0">
     * faces.setFighter(group);
     * </listing>
     */
    public function setFighter(fighterGroup:GameRunFighterGroup = null):void {

        _ui.cacheAsBitmap = false;

        if (!fighterGroup.currentFighter) {
            return;
        }

        _face1.setData(fighterGroup.currentFighter.data);
        switch (fighterGroup.currentFighter.data) {
        case fighterGroup.fighter1:
            _face2.setData(fighterGroup.fighter2);
            _face3.setData(fighterGroup.fighter3);
            break;
        case fighterGroup.fighter2:
            _face2.setData(fighterGroup.fighter3);
            _face3.setData(null);
            break;
        case fighterGroup.fighter3:
            _face2.setData(null);
            _face3.setData(null);
            break;
        }

        _ui.cacheAsBitmap = true;
    }

    /**
     * 把朝向交给三张脸。脸的实现是空的。
     *
     * @param v 朝向。
     * @example
     * <listing version="3.0">
     * faces.setDirect(1);
     * </listing>
     */
    public function setDirect(v:int):void {
        _face1.setDirect(v);
        _face2.setDirect(v);
        _face3.setDirect(v);
    }

}
}
