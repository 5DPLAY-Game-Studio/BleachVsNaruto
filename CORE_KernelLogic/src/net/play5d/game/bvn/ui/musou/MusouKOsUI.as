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

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.kyo.display.bitmap.BitmapFontText;

public class MusouKOsUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function MusouKOsUI(ui:Sprite) {
        _text = new BitmapFontText(AssetManager.I.getFont('font1'));
        ui.addChild(_text);
    }
    private var _ct:Sprite;
    private var _text:BitmapFontText;

    public function update():void {
        _text.text = GameCtrl.I.getMosouCtrl().gameRunData.koNum.toString();
    }

}
}
