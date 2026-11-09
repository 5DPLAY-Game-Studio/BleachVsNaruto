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

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.vos.FighterVO;

/**
 * 血条旁的头像。<code>setDirect</code> 是空的。每次设置有数据时都再加一张图，不先清掉旧的。没有图时只保持可见。传入 null 则藏起。
 */
public class FightFaceUI {

    /**
     * 记下头像影片。
     *
     * @param ui 头像影片。null 时抛错。
     * @throws TypeError 影片为 null 时。
     */
    public function FightFaceUI(ui:$fight$MC_hpBarFace) {
        _ui = ui;
    }
    private var _ui:$fight$MC_hpBarFace;

    /**
     * 显示这个角色的头像。null 时藏起。有图就追加到容器里。
     *
     * @param v 角色数据。
     * @example
     * <listing version="3.0">
     * face.setData(data);
     * </listing>
     */
    public function setData(v:FighterVO):void {
        if (!v) {
            _ui.visible = false;
            return;
        }

        _ui.visible = true;

        var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(v);
        if (faceImg) {
            _ui.ct.addChild(faceImg);
        }
    }

    /**
     * 空实现。
     *
     * @param v 朝向。不使用。
     */
    public function setDirect(v:int):void {
    }

}
}
