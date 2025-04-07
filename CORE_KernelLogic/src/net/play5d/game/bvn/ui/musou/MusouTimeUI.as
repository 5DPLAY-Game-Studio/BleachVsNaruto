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
import flash.display.Sprite;
import flash.text.TextField;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.kyo.utils.KyoTimerFormat;

public class MusouTimeUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function MusouTimeUI(ui:Sprite) {
        _ui  = ui;
        _txt = ui.getChildByName('text') as TextField;
    }
    private var _ui:Sprite;
    private var _txt:TextField;

    public function renderAnimate():void {
        if (_txt) {
            var sec:int = GameCtrl.I.getMosouCtrl().gameRunData.gameTime / GameConfig.FPS_ANIMATE;
            _txt.text   = KyoTimerFormat.secToTime(sec);
        }
    }
}
}
