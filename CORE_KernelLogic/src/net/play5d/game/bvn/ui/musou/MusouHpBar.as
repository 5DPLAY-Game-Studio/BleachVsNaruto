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

import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.HpBarLerp;

public class MusouHpBar {

    public function MusouHpBar(bar:DisplayObject, bar2:DisplayObject) {
        _lerp = new HpBarLerp(bar, bar2);
    }
    private var _fighter:FighterMain;
    private var _lerp:HpBarLerp;

    public function setFighter(fighter:FighterMain):void {
        _fighter = fighter;
    }

    public function render():void {
        _lerp.render(_fighter);
    }

}
}
