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

package net.play5d.game.bvn.views.effects {
import flash.geom.ColorTransform;

import net.play5d.game.bvn.data.EffectVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class BuffEffectView extends EffectView {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public function BuffEffectView(data:EffectVO) {
        super(data);
        this.loopPlay = true;
    }
    private var _fighter:FighterMain;
    private var _buff:FighterBuffVO;

    public override function setTarget(v:IGameSprite):void {
        super.setTarget(v);

        if (v is FighterMain) {
            _fighter = v as FighterMain;
        }

        if (_fighter && _data.targetColorOffset) {
            var ct:ColorTransform = new ColorTransform();
            ct.redOffset          = _data.targetColorOffset[0];
            ct.greenOffset        = _data.targetColorOffset[1];
            ct.blueOffset         = _data.targetColorOffset[2];
            _fighter.changeColor(ct);
        }
    }

    public override function render():void {
        super.render();
        if (_buff.finished) {
            if (_data.targetColorOffset && _fighter) {
                _fighter.resumeColor();
            }
            remove();
        }
        else {
            if (_fighter) {
                setPos(_fighter.x, _fighter.y);
            }
        }
    }

    public function setBuff(v:FighterBuffVO):void {
        _buff = v;
    }

}
}
