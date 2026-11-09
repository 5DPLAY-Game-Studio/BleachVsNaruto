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

package net.play5d.game.bvn.ui.musou.enemy {
import flash.display.DisplayObject;
import flash.display.Sprite;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.kyo.utils.KyoMath;

/**
 * 敌人血条。血量比例夹在 0.0001 和 1 之间。<code>destroy</code> 是空的。没有头像图时不往容器里加东西。
 */
public class EnemyHpUI {

    /**
     * 建血条并尝试放上头像。角色为 null，或没有脸容器时抛错。
     *
     * @param fighter 敌人。
     * @throws TypeError 角色或脸容器缺失时。
     */
    public function EnemyHpUI(fighter:FighterMain) {
        _ui      = new $musou$MC_enemyHpBar();
        _bar     = _ui.getChildByName('bar');
        _faceCt  = _ui.getChildByName('ct_face') as Sprite;
        _fighter = fighter;

        var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
        if (faceImg) {
            _faceCt.addChild(faceImg);
        }
    }
    private var _ui:$musou$MC_enemyHpBar;
    private var _fighter:FighterMain;
    private var _bar:DisplayObject;
    private var _faceCt:Sprite;

    /**
     * 这条血条对应的角色。
     *
     * @return 角色。
     * @example
     * <listing version="3.0">
     * var fighter:FighterMain = bar.getFighter();
     * </listing>
     */
    public function getFighter():FighterMain {
        return _fighter;
    }

    /**
     * 血条显示对象。
     *
     * @return 显示对象。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = bar.getUI();
     * </listing>
     */
    public function getUI():DisplayObject {
        return _ui;
    }

    /**
     * 按血量改缩放。
     *
     * @return 角色还活着时为 true。
     * @throws TypeError 血条缺失时。
     * @example
     * <listing version="3.0">
     * var alive:Boolean = bar.render();
     * </listing>
     */
    public function render():Boolean {
        _bar.scaleX = KyoMath.fixRange(_fighter.hpPercent, 0.0001, 1);

        return _fighter.isAlive;
    }

    /**
     * 空实现。显示对象还留着。
     *
     * @example
     * <listing version="3.0">
     * bar.destroy();
     * </listing>
     */
    public function destroy():void {

    }


}
}
