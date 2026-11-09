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

import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 跟着角色走的循环增益特效。构造时就打开循环。
 *
 * <p>还没 <code>setBuff</code> 就渲染会抛错。增益结束时，有目标色偏就恢复颜色并移除。目标不是角色时不改色，也不跟随；之前设过的角色还留着。</p>
 */
public class BuffEffectView extends EffectView {

    /**
     * 用特效数据创建，并打开循环。
     *
     * @param data 特效数据。null 时抛错。
     * @throws TypeError 数据为 null 时。
     */
    public function BuffEffectView(data:EffectVO) {
        super(data);
        this.loopPlay = true;
    }
    private var _fighter:FighterMain;
    private var _buff:FighterBuffVO;

    /**
     * 记下目标。是角色且数据有色偏时，按三个偏移改色。色偏不是数组时抛错，不够三项时缺的偏移变成 NaN。
     *
     * @param v 目标。不是角色时不改色。
     * @throws TypeError 色偏不是数组时。
     * @example
     * <listing version="3.0">
     * view.setTarget(fighter);
     * </listing>
     */
    public override function setTarget(v:IGameSprite):void {
        super.setTarget(v);

        if (v is FighterMain) {
            _fighter = v as FighterMain;
        }

        if (_fighter && _data.targetColorOffset) {
            var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.redOffset          = _data.targetColorOffset[0];
            colorTransform.greenOffset        = _data.targetColorOffset[1];
            colorTransform.blueOffset         = _data.targetColorOffset[2];
            _fighter.changeColor(colorTransform);
        }
    }

    /**
     * 增益结束就恢复颜色并移除，否则跟到角色脚下。增益还没设置时抛错。
     *
     * @throws TypeError 增益为 null 时。
     * @example
     * <listing version="3.0">
     * view.render();
     * </listing>
     */
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

    /**
     * 记下增益。传 null 时，下次渲染抛错。
     *
     * @param v 增益。
     * @example
     * <listing version="3.0">
     * view.setBuff(buff);
     * </listing>
     */
    public function setBuff(v:FighterBuffVO):void {
        _buff = v;
    }

}
}
