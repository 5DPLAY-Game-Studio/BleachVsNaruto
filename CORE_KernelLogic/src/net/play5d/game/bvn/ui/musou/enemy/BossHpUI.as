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

package net.play5d.game.bvn.ui.musou.enemy {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.ui.HpBarLerp;

public class BossHpUI {

    public function BossHpUI(mc:Sprite) {
        _ui = mc;

        _bar    = mc.getChildByName('bar');
        _bar2   = mc.getChildByName('redbar');
        _faceCt = mc.getChildByName('ct_face') as Sprite;
        _lerp   = new HpBarLerp(_bar, _bar2);
    }
    private var _ui:Sprite;
    private var _bar:DisplayObject;
    private var _bar2:DisplayObject;
    private var _faceCt:Sprite;
    private var _fighter:FighterMain;
    private var _lerp:HpBarLerp;
    private var _enabled:Boolean = true;

    public function isEnabled():Boolean {
        return _ui.visible;
    }

    public function enabled(v:Boolean):void {
        _ui.visible = v;
    }

    public function setFighter(f:FighterMain):void {
        if (!f) {
            _fighter = null;
            enabled(false);
            return;
        }
        _fighter = f;
        enabled(true);
        updateFace();
    }

    public function render():void {
        if (!_enabled || !_fighter) {
            return;
        }

        _lerp.render(_fighter);
    }

    private function updateFace():void {
        if (!_faceCt || !_fighter) {
            return;
        }
        _faceCt.removeChildren();

        if (!_fighter || !_fighter.data) {
            return;
        }

        var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data, new Point(37, 37));
        if (faceImg) {
            _faceCt.addChild(faceImg);
        }

    }

}
}
