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

public class EnemyHpFollowUI {
    include '../../../../../../../../include/_INCLUDE_.as';

    public function EnemyHpFollowUI(fighter:FighterMain) {
        _ui        = new mosou_enemyhpbarmc2();
        _ui.scaleX = _ui.scaleY = 0.5;
        _bar       = _ui.getChildByName('barmc');
        _fighter   = fighter;

        _ui.visible = false;
    }
    private var _ui:mosou_enemyhpbarmc2;
    private var _fighter:FighterMain;
    private var _bar:DisplayObject;
    private var _showDelay:int;

    public function getFighter():FighterMain {
        return _fighter;
    }

    public function getUI():DisplayObject {
        return _ui;
    }

    public function active():void {
        _ui.visible = true;
        _showDelay  = GameConfig.FPS_GAME * 3;
    }

    public function render():Boolean {
        if (!_fighter) {
            return false;
        }

        if (!_ui.visible) {
            return _fighter.isAlive;
        }

        var val:Number = _fighter.hp / _fighter.hpMax;
        if (val < 0.0001) {
            val = 0.0001;
        }
        if (val > 1) {
            val = 1;
        }

        _ui.x = _fighter.x;
        _ui.y = _fighter.y - 50;

        _bar.scaleX = val;

        if (--_showDelay <= 0) {
            _ui.visible = false;
        }

        return _fighter.isAlive;
    }

    public function destory():void {
        _fighter = null;
        _bar     = null;
        _ui      = null;
    }


}
}
