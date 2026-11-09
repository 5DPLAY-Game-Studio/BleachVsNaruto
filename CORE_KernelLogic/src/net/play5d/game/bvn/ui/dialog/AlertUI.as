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

package net.play5d.game.bvn.ui.dialog {
/**
 * 只有确认按钮的提示。构造时就建好，否按钮藏起，确认钮放到 253。
 */
public class AlertUI extends MusouConfirmUI {

    /**
     * 建好界面并藏起否按钮。
     */
    public function AlertUI() {
        super();
        build();
    }

    /**
     * 藏起否按钮，并把确认钮放到 253。
     */
    protected override function build():void {
        super.build();

        _noBtn.visible = false;

        _yesBtn.x = 253;
    }


}
}
