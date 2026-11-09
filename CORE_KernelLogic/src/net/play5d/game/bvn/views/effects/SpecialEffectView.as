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
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 火、冰、雷击中后的持续效果。
 *
 * <p>目标不是角色时不改色，渲染也不跟随。倒地、倒地弹起或回到普通状态时跳到标签 <code>finish</code>，有色偏就恢复颜色，之后不再跟位置。标签不存在时帧不变，但跟随已经停了。不会自己移除。</p>
 */
public class SpecialEffectView extends EffectView {

    /**
     * 用特效数据创建。
     *
     * @param data 特效数据。null 时抛错。
     * @throws TypeError 数据为 null 时。
     */
    public function SpecialEffectView(data:EffectVO) {
        super(data);
    }
    private var _fighter:FighterMain;
    private var _finished:Boolean;

    /**
     * 记下目标。是角色且有色偏时按三个偏移改色。色偏不是数组时抛错，不够三项时缺的偏移变成 NaN。
     *
     * @param v 目标。
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
            if (_data.targetColorOffset) {
                var colorTransform:ColorTransform = new ColorTransform();
                colorTransform.redOffset          = _data.targetColorOffset[0];
                colorTransform.greenOffset        = _data.targetColorOffset[1];
                colorTransform.blueOffset         = _data.targetColorOffset[2];
                _fighter.changeColor(colorTransform);
            }
        }
    }

    /**
     * 开始播放，并把结束标记清掉。
     *
     * @param x 原点横坐标。默认 0。
     * @param y 原点纵坐标。默认 0。
     * @param direct 方向。默认 1。
     * @param playSound 是否播声音。默认 true。
     * @example
     * <listing version="3.0">
     * view.start(x, y, 1);
     * </listing>
     */
    public override function start(x:Number = 0, y:Number = 0, direct:int = 1, playSound:Boolean = true):void {
        super.start(x, y, direct, playSound);
        _finished = false;
    }

    /**
     * 跟着角色，或在倒地和普通状态时结束跟随。已经结束，或没有角色时直接返回。
     *
     * @example
     * <listing version="3.0">
     * view.render();
     * </listing>
     */
    public override function render():void {
        super.render();

        if (_finished) {
            return;
        }
        if (!_fighter) {
            return;
        }

        switch (_fighter.actionState) {
        case FighterActionState.HURT_DOWN:
        case FighterActionState.HURT_DOWN_TAN:
        case FighterActionState.NORMAL:
            gotoAndPlay('finish');
            _finished = true;
            if (_data.targetColorOffset) {
                _fighter.resumeColor();
            }
            break;
        default:
            setPos(_fighter.x, _fighter.y);
        }

    }

}
}
