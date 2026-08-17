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
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.EffectModel;
import net.play5d.game.bvn.data.HitType;
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.ctrler.effect.EffectManager;

/**
 * 命中 / 防御 / 刚体命中特效域。
 *
 * @see EffectCtrl
 */
public class EffectHitHandler {

    /** @private */
    private var _ctrl:EffectCtrl;
    /** @private */
    private var _manager:EffectManager;
    /** @private */
    private var _hitFocusTarget:IGameSprite;

    /**
     * 绑定门面与特效管理器。
     *
     * @param ctrl <code>EffectCtrl</code> 门面。
     * @param manager 特效 VO / View 管理器。
     * @example
     * <listing version="3.0">
     * handler.bind(EffectCtrl.I, manager);
     * </listing>
     */
    public function bind(ctrl:EffectCtrl, manager:EffectManager):void {
        _ctrl    = ctrl;
        _manager = manager;
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
        _ctrl            = null;
        _manager         = null;
        _hitFocusTarget  = null;
    }

    /**
     * 命中停顿结束时恢复镜头（若曾聚焦受击目标）。
     *
     * @example
     * <listing version="3.0">
     * handler.clearHitFocusOnFreezeEnd();
     * </listing>
     */
    public function clearHitFocusOnFreezeEnd():void {
        if (_hitFocusTarget) {
            _hitFocusTarget = null;
            GameCtrl.I.gameState.cameraResume();
        }
    }

    /**
     * 命中特效。
     *
     * @param hitvo 命中数据。
     * @param hitRect 命中矩形。
     * @param target 受击目标。
     * @example
     * <listing version="3.0">
     * handler.doHitEffect(hitVO, rect, fighter);
     * </listing>
     */
    public function doHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite = null):void {
        if (Debugger.HIDE_HITEFFECT) {
            return;
        }

        var effect:EffectVO = _manager.getHitEffectVOByHitVO(hitvo, target);
        if (!effect) {
            return;
        }

        var ex:Number = hitRect.x + hitRect.width / 2;
        var ey:Number = hitRect.y + hitRect.height / 2;

        var direct:int = 1;
        if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
            direct = (
                    hitvo.owner as IGameSprite
            ).direct;
        }

        if (hitvo.slowDown > 0) {
            _ctrl.slowDown(1.5, hitvo.slowDown * 1000);
        }

        if (hitvo.focusTarget) {
            _hitFocusTarget = target;
            GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
        }
        else {
            if (_hitFocusTarget && _hitFocusTarget == target) {
                _hitFocusTarget = null;
            }
        }

        _ctrl.doEffectVO(effect, ex, ey, direct, target);
    }

    /**
     * 防御特效。
     *
     * @param hitvo 命中数据。
     * @param hitRect 命中矩形。
     * @param defenseType 防御类型。
     * @param target 防御方。
     * @example
     * <listing version="3.0">
     * handler.doDefenseEffect(hitVO, rect, type);
     * </listing>
     */
    public function doDefenseEffect(
            hitvo:HitVO, hitRect:Rectangle, defenseType:int, target:IGameSprite = null
    ):void {
        var effect:EffectVO = _manager.getDefenseEffectVOByHitVO(hitvo, defenseType, target);

        if (!effect) {
            return;
        }

        var ex:Number = hitRect.x + hitRect.width / 2;
        var ey:Number = hitRect.y + hitRect.height / 2;

        if (effect.shake) {
            if (effect.shake.pow != undefined && effect.shake.pow != 0) {
                effect.shake.x = 0;
                effect.shake.y = effect.shake.pow;
            }
        }

        var direct:int = 1;
        if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
            direct = (
                    hitvo.owner as IGameSprite
            ).direct;
        }

        _ctrl.doEffectVO(effect, ex, ey, direct, target);
    }

    /**
     * 刚体命中特效。
     *
     * @param hitvo 命中数据。
     * @param hitRect 命中矩形。
     * @param target 刚体目标。
     * @example
     * <listing version="3.0">
     * handler.doSteelHitEffect(hitVO, rect, fighter);
     * </listing>
     */
    public function doSteelHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite):void {
        if (Debugger.HIDE_HITEFFECT) {
            return;
        }

        var effect:EffectVO;

        switch (hitvo.hitType) {
        case HitType.NONE:
            return;
        case HitType.KAN:
        case HitType.KAN_HEAVY:
            effect = EffectModel.I.getEffect('steel_hit_kan');
            break;
        case HitType.DA:
        case HitType.DA_HEAVY:
            effect = EffectModel.I.getEffect('steel_hit_qdj');
            break;
        default:
            effect = EffectModel.I.getEffect('steel_hit_mfdj');
        }

        if (!effect) {
            return;
        }

        var ex:Number = hitRect.x + hitRect.width / 2;
        var ey:Number = hitRect.y + hitRect.height / 2;

        var direct:int = 1;
        if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
            direct = (
                    hitvo.owner as IGameSprite
            ).direct;
        }

        _ctrl.doEffectVO(effect, ex, ey, direct, target);
    }
}
}
