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

package net.play5d.game.bvn.ctrler.effect {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.Dictionary;

import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.views.effects.ShadowEffectView;

/**
 * 残影域。
 *
 * @see EffectCtrl
 */
public class EffectShadowHandler {

    /** @private */
    private var _effectLayer:Sprite;
    /** @private */
    private var _shadowEffects:Dictionary;

    /**
     * 绑定特效层并重置残影表。
     *
     * @param effectLayer 特效显示层。
     * @example
     * <listing version="3.0">
     * handler.initialize(effectLayer);
     * </listing>
     */
    public function initialize(effectLayer:Sprite):void {
        _effectLayer   = effectLayer;
        _shadowEffects = new Dictionary();
    }

    /**
     * 释放引用。
     *
     * @example
     * <listing version="3.0">
     * handler.destroy();
     * </listing>
     */
    public function destroy():void {
        _effectLayer   = null;
        _shadowEffects = null;
    }

    /**
     * 开始残影。
     *
     * @param target 目标显示对象。
     * @param r 红色通道偏移。
     * @param g 绿色通道偏移。
     * @param b 蓝色通道偏移。
     * @param owner 所属精灵。
     * @example
     * <listing version="3.0">
     * handler.startShadow(disp, 0, 0, 0, fighter);
     * </listing>
     */
    public function startShadow(
            target:DisplayObject, r:int = 0, g:int = 0, b:int = 0, owner:BaseGameSprite = null
    ):void {
        if (!EffectCtrl.SHADOW_ENABLED) {
            return;
        }

        var sv:ShadowEffectView = _shadowEffects[target];

        if (sv) {
            sv.r          = r;
            sv.g          = g;
            sv.b          = b;
            sv.owner      = owner;
            sv.stopShadow = false;
            return;
        }

        sv           = new ShadowEffectView(target, r, g, b, owner);
        sv.onRemove  = removeShadow;
        sv.container = _effectLayer;

        _shadowEffects[target] = sv;
    }

    /**
     * 停止残影（淡出后移除）。
     *
     * @param target 目标显示对象。
     * @example
     * <listing version="3.0">
     * handler.endShadow(disp);
     * </listing>
     */
    public function endShadow(target:DisplayObject):void {
        if (!EffectCtrl.SHADOW_ENABLED) {
            return;
        }

        if (!_shadowEffects) {
            return;
        }
        var sv:ShadowEffectView = _shadowEffects[target];
        if (sv) {
            sv.stopShadow = true;
        }
    }

    /**
     * 动画帧推进残影。
     *
     * @example
     * <listing version="3.0">
     * handler.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        if (!_shadowEffects) {
            return;
        }
        for each(var s:ShadowEffectView in _shadowEffects) {
            s.render();
        }
    }

    /** @private */
    private function removeShadow(s:ShadowEffectView):void {
        if (!_shadowEffects) {
            return;
        }
        delete _shadowEffects[s.target];
    }
}
}
