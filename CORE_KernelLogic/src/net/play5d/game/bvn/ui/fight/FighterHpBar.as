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
import flash.filters.DropShadowFilter;

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.HpBarLerp;
import net.play5d.kyo.display.BitmapText;

public class FighterHpBar {

    public function FighterHpBar(ui:$fight$MC_hpBarMc) {
        _ui     = ui;
        _bar    = _ui.bar;
        _redbar = _ui.redbar;
        _lerp   = new HpBarLerp(_bar, _redbar);

        if (GameUI.SHOW_HP_TEXT) {
            _hpText      = new BitmapText(true, 0xffffff, [new DropShadowFilter()]);
            _hpText.font = 'Arial';
            _hpText.x    = 120;
            _hpText.y    = 2;
            ui.addChild(_hpText);

            _damageText         = new BitmapText(true, 0xffff00, [new DropShadowFilter()]);
            _damageText.font    = 'Arial';
            _damageText.x       = 10;
            _damageText.y       = 2;
            _damageText.visible = false;
            ui.addChild(_damageText);

        }

    }
    private var _bar:DisplayObject;
    private var _redbar:DisplayObject;
    private var _lerp:HpBarLerp;

    private var _fighter:FighterMain;

    private var _hpText:BitmapText;
    private var _damageText:BitmapText;

    private var _direct:int;

    private var _ui:$fight$MC_hpBarMc;

    public function get ui():DisplayObject {
        return _ui;
    }

    public function setDirect(v:int):void {
        _direct = v;
        if (v < 0) {
            if (_hpText) {
                _hpText.scaleX = -1;
            }
            if (_damageText) {
                _damageText.scaleX = -1;
                _damageText.x      = 40;
            }
        }
    }

    public function destroy():void {
        _fighter = null;
        _lerp    = null;

        if (_hpText) {
            _hpText.destroy();
            _hpText = null;
        }

        if (_damageText) {
            _damageText.destroy();
            _damageText = null;
        }
    }

    public function setFighter(v:FighterMain):void {
        _fighter = v;
    }

    public function render():void {
        _lerp.render(_fighter);

        if (_hpText) {
            _hpText.text = _fighter.hp.toString();
        }

        if (_damageText) {
            if (_fighter.currentHurtDamage() > 0) {
                _damageText.text    = '-' + _fighter.currentHurtDamage().toString();
                _damageText.visible = true;
            }
            else {
                _damageText.visible = false;
            }
        }

    }

}
}
