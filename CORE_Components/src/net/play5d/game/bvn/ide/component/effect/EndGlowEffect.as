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

/**
 * 结束发光 IDE 组件。
 *
 * <p>仅面向 FighterMain 时间轴组件：调用 <code>$effect_ctrler.endGlow</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.GlowEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class EndGlowEffect extends BaseEffect {

    /**
     * 绑定结束发光，动作帧调用 <code>endGlow</code>。
     *
     * @example
     * <listing version="3.0">
     * new EndGlowEffect();
     * </listing>
     */
    public function EndGlowEffect() {
        bindNoArgCall('效果_结束发光', 'endGlow');
    }
}
}
