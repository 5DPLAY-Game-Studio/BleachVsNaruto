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

package net.play5d.game.bvn.ctrler.game_ctrls {
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.game.bvn.fighter.FighterAttacker;

/**
 * 格斗（1v1 / 小队 / 练习等）对局会话。
 *
 * <p>承载 <code>FighterEventCtrl</code>；建局与回合仍由 <code>GameCtrl</code> 负责。</p>
 *
 * @see IFightSession
 * @see FighterEventCtrl
 */
public class VersusFightSession implements IFightSession {

    /** @private */
    private var _fighterEventCtrl:FighterEventCtrl;

    /**
     * @inheritDoc
     */
    public function onGameInitialize():void {
        _fighterEventCtrl = new FighterEventCtrl();
        _fighterEventCtrl.initialize();
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        if (_fighterEventCtrl) {
            _fighterEventCtrl.destroy();
            _fighterEventCtrl = null;
        }
    }

    /**
     * @inheritDoc
     */
    public function getAttacker(name:String, team:int):FighterAttacker {
        return _fighterEventCtrl.getAttacker(name, team);
    }

    /**
     * @inheritDoc
     */
    public function buildGame():void {
    }

    /**
     * @inheritDoc
     */
    public function render():void {
    }

    /**
     * @inheritDoc
     */
    public function renderAnimate():void {
    }

    /**
     * @inheritDoc
     */
    public function allowsRoundTimer():Boolean {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function isFinished():Boolean {
        return false;
    }

    /**
     * @inheritDoc
     */
    public function getMusouCtrl():MusouCtrl {
        return null;
    }
}
}
