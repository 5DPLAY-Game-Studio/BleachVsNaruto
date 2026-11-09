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

/**
 * 钢体受击闪白。只有目标是角色且处于钢体时才改色。
 *
 * <p>普通钢体的三色偏移都是 150。超级钢体把蓝色偏移改成 0，并闪一层黄色。冻结结束时恢复颜色。不是钢体时什么都不做。</p>
 */
public class SteelHitEffect extends EffectView {

    /**
     * 用特效数据创建。
     *
     * @param data 特效数据。null 时抛错。
     * @throws TypeError 数据为 null 时。
     */
    public function SteelHitEffect(data:EffectVO) {
        super(data);
    }
    private var _fighter:FighterMain;

    /**
     * 是钢体角色时改色，并在冻结结束时恢复。其它目标直接返回。
     *
     * @param v 目标。
     * @example
     * <listing version="3.0">
     * view.setTarget(fighter);
     * </listing>
     */
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
