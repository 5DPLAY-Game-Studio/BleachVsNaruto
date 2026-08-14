/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ui {
import flash.display.DisplayObject;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 血条主条与红色滞后条插值。
 *
 * <p>供对战 / 无双 / Boss 血条复用同一套受击延迟与缩放插值。</p>
 *
 * @see net.play5d.game.bvn.ui.fight.FighterHpBar
 * @see net.play5d.game.bvn.ui.musou.MusouHpBar
 */
public class HpBarLerp {

    /**
     * @param bar 主血条（scaleX）。
     * @param redBar 红色滞后条（scaleX）。
     */
    public function HpBarLerp(bar:DisplayObject, redBar:DisplayObject) {
        _bar    = bar;
        _redBar = redBar;
    }

    /** @private */
    private var _bar:DisplayObject;
    /** @private */
    private var _redBar:DisplayObject;
    /** @private */
    private var _hprate:Number = 1;
    /** @private */
    private var _redBarMoving:Boolean;
    /** @private */
    private var _redBarMoveDelay:int;
    /** @private */
    private var _justHurtFly:Boolean;

    /**
     * 按角色当前血量与受击状态推进插值。
     *
     * @param fighter 当前角色。
     * @example
     * <listing version="3.0">
     * lerp.render(fighter);
     * </listing>
     */
    public function render(fighter:FighterMain):void {
        var rate:Number = fighter.hp / fighter.hpMax;

        if (_redBarMoving && rate != _hprate) {
            _redBar.scaleX = _hprate;
            _redBarMoving  = false;
        }

        _hprate            = rate;
        var diff:Number    = _hprate - _bar.scaleX;
        var addRate:Number = diff < 0 ? 0.4 : 0.04;

        if (Math.abs(diff) < 0.01) {
            _bar.scaleX = _hprate;
        }
        else {
            _bar.scaleX += diff * addRate;
        }

        switch (fighter.actionState) {
        case FighterActionState.HURT_ING:
            _redBarMoveDelay = 100;
            break;
        case FighterActionState.HURT_FLYING:
        case FighterActionState.HURT_DOWN:
            if (_redBarMoveDelay > 0) {
                if (!_justHurtFly) {
                    _redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
                    _justHurtFly     = true;
                }
                else {
                    if (_redBarMoveDelay > 0) {
                        _redBarMoveDelay--;
                    }
                }
            }
            break;
        default:
            _redBarMoveDelay = 0;
            _justHurtFly     = false;
        }

        if (_redBarMoveDelay <= 0) {
            var diff2:Number    = _hprate - _redBar.scaleX;
            var addRate2:Number = diff2 < 0 ? 0.1 : 0.02;
            if (Math.abs(diff2) < 0.01) {
                _redBar.scaleX = _hprate;
                _redBarMoving  = false;
            }
            else {
                _redBar.scaleX += diff2 * addRate2;
                _redBarMoving = true;
            }
        }
    }
}
}
