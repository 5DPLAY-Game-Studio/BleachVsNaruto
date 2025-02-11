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

package net.play5d.game.bvn.ui.dialog.select {
import flash.display.MovieClip;

import net.play5d.game.bvn.utils.ResUtils;

public class DotItemUI {
    include '../../../../../../../../include/_INCLUDE_.as';

    public function DotItemUI() {
        _ui               = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dot_mc');
        _ui.mouseChildren = false;
        _ui.buttonMode    = true;
        _ui.gotoAndStop(2);
    }
    public var page:int = 0;
    private var _ui:MovieClip;

    public function getUI():MovieClip {
        return _ui;
    }

    public function focus(v:Boolean):void {
        _ui.gotoAndStop(v ? 1 : 2);
    }
}
}
