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

package net.play5d.game.bvn.ctrl {
import flash.display.Sprite;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ui.QuickTransUI;
import net.play5d.game.bvn.ui.TransUI;

public class StateCtrl {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _i:StateCtrl;

    public static function get I():StateCtrl {
        _i ||= new StateCtrl();
        return _i;
    }

    public function StateCtrl() {
        _transContainer = MainGame.I.root;
    }
    public var transEnabled:Boolean = true;
    private var _transUI:TransUI;
    private var _quickTransUI:QuickTransUI;
    private var _transContainer:Sprite;

    public function transIn(back:Function = null, removeAfterComplete:Boolean = false):void {

        if (!transEnabled) {
            if (back != null) {
                back();
            }
            return;
        }

        addTransUI();

        if (removeAfterComplete) {
            _transUI.fadIn(removeSelf);
        }
        else {
            _transUI.fadIn(back);
        }

        function removeSelf():void {
            if (back != null) {
                back();
            }
            removeTrainsUI();
        }

    }

    public function transOut(back:Function = null, removeAfterComplete:Boolean = true):void {

        if (!transEnabled) {
            if (back != null) {
                back();
            }
            return;
        }

        addTransUI();

        if (removeAfterComplete) {
            _transUI.fadOut(removeSelf);
        }
        else {
            _transUI.fadOut(back);
        }

        function removeSelf():void {
            if (back != null) {
                back();
            }
            removeTrainsUI();
        }

    }

    public function quickTrans(back:Function = null):void {
        if (!_transContainer) {
            if (back != null) {
                back();
            }
            return;
        }
        _quickTransUI ||= new QuickTransUI();
        _transContainer.addChild(_quickTransUI);
        _quickTransUI.fadInAndOut(transCom);

        function transCom():void {
            try {
                _transContainer.removeChild(_quickTransUI);
            }
            catch (e:Error) {
            }
            if (back != null) {
                back();
            }
        }
    }

    public function clearTrans():void {
        removeTrainsUI();
    }

    private function addTransUI():void {
        if (!_transUI) {
            _transUI = new TransUI();
        }

        _transContainer.addChild(_transUI.ui);
    }

    private function removeTrainsUI():void {
        try {
            _transContainer.removeChild(_transUI.ui);
        }
        catch (e:Error) {
        }
    }

}
}
