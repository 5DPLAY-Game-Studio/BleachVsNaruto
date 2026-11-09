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
import net.play5d.kyo.utils.KyoColor;

/**
 * 开始残影 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.shadow</code>。需配对 <code>EndShadowEffect</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.EndShadowEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class ShadowEffect extends BaseEffect {

    /** @private 残影 R */
    private var _r:int = 0;

    /** @private 残影 G */
    private var _g:int = 0;

    /** @private 残影 B */
    private var _b:int = 0;

    /** @private 残影颜色 */
    private var _color:uint = 0xffffff;

    /**
     * 设置残影标题，并按当前颜色刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:ShadowEffect = new ShadowEffect();
     * effect.color = 0x888888;
     * </listing>
     */
    public function ShadowEffect() {
        super.title = '效果_残影';
        refreshPreview();
    }

    /**
     * 残影颜色。
     *
     * @return 颜色值。
     * @default 0xffffff
     */
    public function get color():uint {
        return _color;
    }

    /** @private */
    [Inspectable(name='残影颜色', type='Color', defaultValue='ffffff')]
    public function set color(v:uint):void {
        _color = v;
        _r = KyoColor.getR(_color);
        _g = KyoColor.getG(_color);
        _b = KyoColor.getB(_color);

        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('shadow', [_r, _g, _b]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('shadow', [_r, _g, _b]);
    }
}
}
