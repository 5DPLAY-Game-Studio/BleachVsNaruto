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
 * 添加跟随特效 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.addFollowEffect</code>。</p>
 * <p><code>mcName</code> 须为角色主 MC 上同帧（或稍后出现）的子元件实例名；
 * 若当前帧找不到，控制器会延迟 1 帧重试。</p>
 *
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class FollowEffect extends BaseEffect {

    /** @private 跟随特效 MC 实例名 */
    private var _mcName:String = '';

    /** @private 是否置于身体图层下方 */
    private var _isUnderBody:Boolean = false;

    /**
     * 设置跟随特效标题，并按当前实例名刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:FollowEffect = new FollowEffect();
     * effect.mcName = 'aura_mc';
     * effect.isUnderBody = true;
     * </listing>
     */
    public function FollowEffect() {
        super.title = '效果_跟随特效';
        refreshPreview();
    }

    /**
     * 跟随特效 MC 实例名。
     *
     * <p>对应角色主 MC 上 <code>getChildByName</code> 的子元件名。</p>
     *
     * @return 实例名。
     * @default ''
     */
    public function get mcName():String {
        return _mcName;
    }

    /** @private */
    [Inspectable(name='跟随特效 MC 实例名', type='String', defaultValue='')]
    public function set mcName(v:String):void {
        _mcName = v ? v : '';
        refreshPreview();
    }

    /**
     * 是否置于身体图层下方。
     *
     * @return 在身体下方时为 <code>true</code>。
     * @default false
     */
    public function get isUnderBody():Boolean {
        return _isUnderBody;
    }

    /** @private */
    [Inspectable(name='是否置于身体图层下方', type='Boolean', defaultValue=false)]
    public function set isUnderBody(v:Boolean):void {
        _isUnderBody = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        if (!validateParam('跟随特效 MC 实例名', _mcName)) {
            return;
        }

        invokeEffect('addFollowEffect', [_mcName, _isUnderBody]);
    }

    /** @private */
    private function refreshPreview():void {
        if (!validateParam('跟随特效 MC 实例名', _mcName)) {
            return;
        }

        updateCallPreview('addFollowEffect', [_mcName, _isUnderBody]);
    }
}
}
