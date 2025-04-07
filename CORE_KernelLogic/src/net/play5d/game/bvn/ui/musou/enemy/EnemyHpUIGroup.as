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
import flash.display.Sprite;

import net.play5d.game.bvn.fighter.FighterMain;

public class EnemyHpUIGroup {
    include '../../../../../../../../include/_INCLUDE_.as';

    public function EnemyHpUIGroup(ct:Sprite) {
        _ct  = ct;
        _uis = new Vector.<EnemyHpUI>();
    }
    private var _uis:Vector.<EnemyHpUI>;
    private var _ct:Sprite;

    public function updateFighter(f:FighterMain):void {
        var i:int;
        for (i = 0; i < _uis.length; i++) {
            if (_uis[i].getFighter() == f) {
                return;
            }
        }

        addUI(f);
    }

    public function removeByFighter(f:FighterMain):void {
        var i:int;

        for (i = 0; i < _uis.length; i++) {
            if (_uis[i] && _uis[i].getFighter() == f) {
                removeUI(_uis[i]);
            }
        }

        sortUI();
    }

    public function render():void {
        var i:int;

        var removes:Vector.<EnemyHpUI> = new Vector.<EnemyHpUI>();
        for (i = 0; i < _uis.length; i++) {
            if (!_uis[i].render()) {
                removes.push(_uis[i]);
            }
        }

        if (removes.length > 0) {
            while (removes.length > 0) {
                var e:EnemyHpUI = removes.shift();
                removeUI(e);
            }
            sortUI();
        }

    }


    private function addUI(f:FighterMain):void {
        var ui:EnemyHpUI = new EnemyHpUI(f);
        _uis.push(ui);
        sortUI();
    }

    private function removeUI(ui:EnemyHpUI):void {
        var index:int = _uis.indexOf(ui);
        if (index != -1) {
            _uis.splice(index, 1);
        }
//			_ct.removeChild(ui.getUI());
    }

    private function sortUI():void {
        var i:int, x:int, y:int;
        var len:int = Math.min(_uis.length, 12);

        _ct.removeChildren();

        for (i = 0; i < len; i++) {
            _uis[i].getUI().x = x;
            _uis[i].getUI().y = y;

            x -= 110;
            if ((
                        i + 1
                ) % 4 == 0) {
                x = 0;
                y += 30;
            }

            _ct.addChild(_uis[i].getUI());
        }
    }

}
}
