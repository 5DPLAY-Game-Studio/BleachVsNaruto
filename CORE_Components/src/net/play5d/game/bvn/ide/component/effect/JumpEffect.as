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
 * 跳跃特效 IDE 组件。
 *
 * <p>仅面向 FighterMain 时间轴组件：调用 <code>$effect_ctrler.jump</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class JumpEffect extends BaseEffect {

    /**
     * 绑定跳跃效果，动作帧调用 <code>jump</code>。
     *
     * @example
     * <listing version="3.0">
     * new JumpEffect();
     * </listing>
     */
    public function JumpEffect() {
        bindNoArgCall('效果_跳跃', 'jump');
    }
}
}
