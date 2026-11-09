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

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.kyo.utils.KyoMath;

/**
 * 跟着角色走的短血条。构造后是隐藏的，缩放 0.5。<code>active</code> 后显示大约 3 秒游戏帧再藏起。血量比例夹在 0.0001 和 1。没有角色时渲染返回 false。
 */
public class EnemyHpFollowUI {

    /**
     * 建血条并先隐藏。
     *
     * @param fighter 敌人。可以先传 null。
     */
    public function EnemyHpFollowUI(fighter:FighterMain) {
        _ui        = new $musou$MC_enemyHpBarFollow();
        _ui.scaleX = _ui.scaleY = 0.5;
        _bar       = _ui.getChildByName('barmc');
        _fighter   = fighter;

        _ui.visible = false;
    }
    private var _ui:$musou$MC_enemyHpBarFollow;
    private var _fighter:FighterMain;
    private var _bar:DisplayObject;
    private var _showDelay:int;

    /**
     * 这条血条跟着的角色。
     *
     * @return 角色。销毁后是 null。
     * @example
     * <listing version="3.0">
     * var fighter:FighterMain = bar.getFighter();
     * </listing>
     */
    public function getFighter():FighterMain {
        return _fighter;
    }

    /**
     * 血条显示对象。销毁后是 null。
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
     * 显示血条，并在大约 3 秒游戏帧后由渲染藏起。销毁后抛错。
     *
     * @throws TypeError 已经销毁时。
     * @example
     * <listing version="3.0">
     * bar.active();
     * </listing>
     */
    public function active():void {
        _ui.visible = true;
        _showDelay  = GameConfig.FPS_GAME * 3;
    }

    /**
     * 跟着角色移动并改血量。藏着的时候不改位置，只返回是否还活着。没有角色时返回 false。
     *
     * @return 角色还活着时为 true。没有角色时为 false。
     * @example
     * <listing version="3.0">
     * var alive:Boolean = bar.render();
     * </listing>
     */
    public function render():Boolean {
        if (!_fighter) {
            return false;
        }

        if (!_ui.visible) {
            return _fighter.isAlive;
        }

        _ui.x = _fighter.x;
        _ui.y = _fighter.y - 50;

        _bar.scaleX = KyoMath.fixRange(_fighter.hpPercent, 0.0001, 1);

        if (--_showDelay <= 0) {
            _ui.visible = false;
        }

        return _fighter.isAlive;
    }

    /**
     * 清掉角色和显示对象。之后渲染返回 false。
     *
     * @example
     * <listing version="3.0">
     * bar.destroy();
     * </listing>
     */
    public function destroy():void {
        _fighter = null;
        _bar     = null;
        _ui      = null;
    }


}
}
