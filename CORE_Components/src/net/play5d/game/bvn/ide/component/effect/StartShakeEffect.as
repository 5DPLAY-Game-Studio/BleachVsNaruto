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
 * 开始持续震动 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.startShake</code>。需配对 <code>EndShakeEffect</code>。</p>
 *
 * @see net.play5d.game.bvn.ide.component.effect.EndShakeEffect
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class StartShakeEffect extends BaseEffect {

    /** @private X 轴震动幅度 */
    private var _powX:Number = 0;

    /** @private Y 轴震动幅度 */
    private var _powY:Number = 3;

    /**
     * 设置持续震动标题，并按当前幅度刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:StartShakeEffect = new StartShakeEffect();
     * effect.powY = 6;
     * </listing>
     */
    public function StartShakeEffect() {
        super.title = '效果_开始震动';
        refreshPreview();
    }

    /**
     * X 轴震动幅度。
     *
     * @return X 幅度。
     * @default 0
     */
    public function get powX():Number {
        return _powX;
    }

    /** @private */
    [Inspectable(name='X 轴震动幅度', type='Number', defaultValue=0)]
    public function set powX(v:Number):void {
        _powX = v;
        refreshPreview();
    }

    /**
     * Y 轴震动幅度。
     *
     * @return Y 幅度。
     * @default 3
     */
    public function get powY():Number {
        return _powY;
    }

    /** @private */
    [Inspectable(name='Y 轴震动幅度', type='Number', defaultValue=3)]
    public function set powY(v:Number):void {
        _powY = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        invokeEffect('startShake', [_powX, _powY]);
    }

    /** @private */
    private function refreshPreview():void {
        updateCallPreview('startShake', [_powX, _powY]);
    }
}
}
