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
 * 开始万解 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.startBanKai</code>。需配对 <code>EndBanKaiEffect</code>。</p>
 * <p><code>face</code> 为已通过 <code>defineBishaFace</code> 注册的特写 id；空串表示无特写。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.EndBanKaiEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class BanKaiEffect extends BaseEffect {

    /** @private 万解特写 id */
    private var _face:String = '';

    /**
     * 构造方法。
     */
    public function BanKaiEffect() {
        super.title = '效果_万解';
        refreshPreview();
    }

    /**
     * 万解特写 id。
     *
     * <p>须事先由角色脚本 <code>defineBishaFace</code> 注册；空串表示无特写。</p>
     *
     * @return 特写 id。
     * @default
     */
    public function get face():String {
        return _face;
    }

    /** @private */
    [Inspectable(name='万解特写 id', type='String', defaultValue='')]
    public function set face(v:String):void {
        _face = v ? v : '';
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('startBanKai', [_face ? _face : null]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('startBanKai', [_face ? _face : null]);
    }
}
}
