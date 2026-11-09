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
 * 结束持续震动 IDE 组件。
 *
 * <p>仅面向 FighterMain 时间轴组件：调用 <code>$effect_ctrler.endShake</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.StartShakeEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class EndShakeEffect extends BaseEffect {

    /**
     * 绑定结束持续震动，动作帧调用 <code>endShake</code>。
     *
     * @example
     * <listing version="3.0">
     * new EndShakeEffect();
     * </listing>
     */
    public function EndShakeEffect() {
        bindNoArgCall('效果_结束震动', 'endShake');
    }
}
}
