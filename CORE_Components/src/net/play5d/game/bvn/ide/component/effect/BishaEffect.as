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
 * 开始必杀特写 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.bisha</code>。需配对 <code>EndBishaEffect</code>。</p>
 * <p><code>face</code> 为关键参数，须事先由角色脚本 <code>defineBishaFace</code> 注册；空串视为参数错误。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.EndBishaEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class BishaEffect extends BaseEffect {

    /** @private 是否超必杀 */
    private var _isSuper:Boolean = false;

    /** @private 必杀特写 id */
    private var _face:String = '';

    /**
     * 设置必杀标题，并按当前特写参数刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:BishaEffect = new BishaEffect();
     * effect.face = 'ichigo1';
     * </listing>
     */
    public function BishaEffect() {
        super.title = '效果_必杀';
        refreshPreview();
    }

    /**
     * 是否超必杀。
     *
     * @return 超必杀时为 <code>true</code>。
     * @default false
     */
    public function get isSuper():Boolean {
        return _isSuper;
    }

    /** @private */
    [Inspectable(name='是否超必杀', type='Boolean', defaultValue=false)]
    public function set isSuper(v:Boolean):void {
        _isSuper = v;
        refreshPreview();
    }

    /**
     * 必杀特写 id。
     *
     * <p>关键参数；须事先由角色脚本 <code>defineBishaFace</code> 注册。</p>
     *
     * @return 特写 id。
     * @default ''
     */
    public function get face():String {
        return _face;
    }

    /** @private */
    [Inspectable(name='必杀特写 id', type='String', defaultValue='')]
    public function set face(v:String):void {
        _face = v ? v : '';
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        if (!validateParam('必杀特写 id', _face)) {
            return;
        }

        invokeEffect('bisha', [_isSuper, _face]);
    }

    /** @private */
    private function refreshPreview():void {
        if (!validateParam('必杀特写 id', _face)) {
            return;
        }

        updateCallPreview('bisha', [_isSuper, _face]);
    }
}
}
