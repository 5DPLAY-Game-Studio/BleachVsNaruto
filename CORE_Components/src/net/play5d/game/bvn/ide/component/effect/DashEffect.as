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
 * 瞬步特效 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.dash</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class DashEffect extends BaseEffect {

    /** @private 是否播放音效 */
    private var _playSound:Boolean = true;

    /**
     * 设置瞬步标题，并按是否播放音效刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:DashEffect = new DashEffect();
     * effect.playSound = false;
     * </listing>
     */
    public function DashEffect() {
        super.title = '效果_瞬步';
        refreshPreview();
    }

    /**
     * 是否播放音效。
     *
     * @return 播放音效时为 <code>true</code>。
     * @default true
     */
    public function get playSound():Boolean {
        return _playSound;
    }

    /** @private */
    [Inspectable(name='是否播放音效', type='Boolean', defaultValue=true)]
    public function set playSound(v:Boolean):void {
        _playSound = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('dash', [_playSound]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('dash', [_playSound]);
    }
}
}
