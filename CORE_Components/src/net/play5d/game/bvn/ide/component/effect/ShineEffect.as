/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ide.component.effect {
import net.play5d.game.bvn.ide.component.BaseEffect;
import net.play5d.game.bvn.ide.utils.ColorUtils;

/**
 * 闪光特效 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.shine</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class ShineEffect extends BaseEffect {

    /** @private 闪光颜色 */
    private var _color:uint = 0xffffff;

    /**
     * 设置闪光标题，并按当前颜色刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:ShineEffect = new ShineEffect();
     * effect.color = 0xffcc00;
     * </listing>
     */
    public function ShineEffect() {
        super.title = '效果_闪光';
        refreshPreview();
    }

    /**
     * 闪光颜色。
     *
     * @return 颜色值。
     * @default 0xffffff
     */
    public function get color():uint {
        return _color;
    }

    /** @private */
    [Inspectable(name='闪光颜色', type='Color', defaultValue='ffffff')]
    public function set color(v:uint):void {
        _color = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('shine', [_color]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('shine', [ColorUtils.asLiteral(_color)]);
    }
}
}
