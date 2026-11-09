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
 * 慢放特效 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.slowDown</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class SlowDownEffect extends BaseEffect {

    /** @private 慢放时长（秒） */
    private var _time:Number = 0;

    /**
     * 设置慢放标题，并按当前时长刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:SlowDownEffect = new SlowDownEffect();
     * effect.time = 0.4;
     * </listing>
     */
    public function SlowDownEffect() {
        super.title = '效果_慢放';
        refreshPreview();
    }

    /**
     * 慢放时长（秒）。
     *
     * @return 时长。
     * @default 0
     */
    public function get time():Number {
        return _time;
    }

    /** @private */
    [Inspectable(name='慢放时长（秒）', type='Number', defaultValue=0)]
    public function set time(v:Number):void {
        _time = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('slowDown', [_time]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('slowDown', [_time]);
    }
}
}
