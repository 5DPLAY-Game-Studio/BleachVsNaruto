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
 * 无双对局会话。
 *
 * <p>包装 <code>MusouCtrl</code>，供 <code>GameCtrl</code> 经 <code>IFightSession</code> 统一调度。</p>
 *
 * @see IFightSession
 * @see MusouCtrl
 */
public class MusouFightSession implements IFightSession {

    /** @private */
    private var _musouCtrl:MusouCtrl;

    /**
     * 创建并初始化无双控制器（对应原 <code>GameCtrl.initMusouGame</code>）。
     */
    public function MusouFightSession() {
        _musouCtrl = new MusouCtrl();
        _musouCtrl.initialize();
    }

    /**
     * @inheritDoc
     */
    public function onGameInitialize():void {
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        if (_musouCtrl) {
            _musouCtrl.destroy();
            _musouCtrl = null;
        }
    }

    /**
     * @inheritDoc
     */
    public function getAttacker(name:String, team:int):FighterAttacker {
        return _musouCtrl.getFighterEventCtrl().getAttacker(name, team);
    }

    /**
     * @inheritDoc
     */
    public function buildGame():void {
        _musouCtrl.buildGame();
    }

    /**
     * @inheritDoc
     */
    public function render():void {
        _musouCtrl.render();
    }

    /**
     * @inheritDoc
     */
    public function renderAnimate():void {
        _musouCtrl.renderAnimate();
    }

    /**
     * @inheritDoc
     */
    public function allowsRoundTimer():Boolean {
        return false;
    }

    /**
     * @inheritDoc
     */
    public function isFinished():Boolean {
        return _musouCtrl.getGameFinished();
    }

    /**
     * @inheritDoc
     */
    public function getMusouCtrl():MusouCtrl {
        return _musouCtrl;
    }
}
}
