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
import flash.display.Sprite;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.kyo.utils.KyoMath;

/**
 * 小血条和气条。比例夹在 0.0001 和 1 之间。气按 300 为满。没有角色时渲染直接返回，设置 null 时换头像会抛错。
 */
public class MusouMiniHpBar {

    /**
     * 记下界面。
     *
     * @param ui 小血条影片。null 时抛错。
     * @throws TypeError 界面为 null 时。
     */
    public function MusouMiniHpBar(ui:$musou$MC_miniHpBar) {
        _ui = ui;
    }
    private var _ui:$musou$MC_miniHpBar;
    private var _fighter:FighterMain;

    /**
     * 换角色并刷新头像。传 null 时读数据会抛错。没有头像图时，旧头像还留着。
     *
     * @param f 角色。
     * @throws TypeError 角色为 null 时。
     * @example
     * <listing version="3.0">
     * bar.setFighter(fighter);
     * </listing>
     */
    public function setFighter(f:FighterMain):void {
        _fighter = f;
        updateFace();
    }

    /**
     * 刷新血和气的缩放。没有角色时直接返回。
     *
     * @example
     * <listing version="3.0">
     * bar.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        if (!_fighter) {
            return;
        }
        _ui.bar_hp.scaleX = KyoMath.fixRange(_fighter.hpPercent, 0.0001, 1);
        _ui.bar_qi.scaleX = KyoMath.fixRange(_fighter.qi / 300, 0.0001, 1);
    }

    private function updateFace():void {
        var ct:Sprite = _ui.face.getChildByName('ct') as Sprite;
        if (ct) {
            var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
            if (faceImg) {
                ct.removeChildren();
                ct.addChild(faceImg);
            }
        }

    }

}
}
