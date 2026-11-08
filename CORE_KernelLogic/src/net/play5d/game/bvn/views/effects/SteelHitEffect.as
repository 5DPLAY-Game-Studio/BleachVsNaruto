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

import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;

public class SteelHitEffect extends EffectView {

    public function SteelHitEffect(data:EffectVO) {
        super(data);
    }
    private var _fighter:FighterMain;

    public override function setTarget(v:IGameSprite):void {
        super.setTarget(v);

        if (v is FighterMain) {

            _fighter = v as FighterMain;

            if (_fighter.isSteelBody) {
                var colorTransform:ColorTransform = new ColorTransform();
                colorTransform.redOffset          = 150;
                colorTransform.greenOffset        = 150;
                colorTransform.blueOffset         = 150;

                if (_fighter.isSuperSteelBody) {
                    colorTransform.blueOffset = 0;
                    EffectCtrl.I.shine(0xffff00, 0.3);
                }

                _fighter.changeColor(colorTransform);
                EffectCtrl.I.setOnFreezeOver(function ():void {
                    _fighter.resumeColor();
                });
            }

        }


    }

}
}
