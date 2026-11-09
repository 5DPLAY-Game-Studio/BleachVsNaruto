/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
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
import flash.utils.Dictionary;

import net.play5d.game.bvn.data.EffectModel;
import net.play5d.game.bvn.data.vos.EffectVO;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.views.effects.BuffEffectView;
import net.play5d.game.bvn.views.effects.EffectView;
import net.play5d.game.bvn.views.effects.ShineEffectView;
import net.play5d.game.bvn.views.effects.SpecialEffectView;
import net.play5d.game.bvn.views.effects.SteelHitEffect;

/**
 * 特效视图和受击特效数据的缓存。
 *
 * <p>受击和防御按 <code>HitVO</code> 对象引用分开缓存普通与无双小兵。后查到的那一种会整份换掉缓存，先查到的另一种下次要重新取。
 * 没查到数据时写入的 <code>null</code> 不会留下，下次仍会再查。视图按同一份 <code>EffectVO</code> 复用已经停掉的实例。</p>
 *
 * @see EffectCacheVO
 * @see EffectCtrl
 */
public class EffectManager {

    /** @private */
    private var _viewCache:Dictionary                = new Dictionary();
    /** @private */
    private var _hitCache:Dictionary                 = new Dictionary();
    /** @private */
    private var _defCache:Dictionary                 = new Dictionary();
    /** @private */
    private var _shineCache:Vector.<ShineEffectView> = new Vector.<ShineEffectView>();

    /**
     * 销毁已创建的视图并清空缓存。
     *
     * <p>之后再取特效会抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * manager.destroy();
     * </listing>
     */
    public function destroy():void {
        for each(var i:Vector.<EffectView> in _viewCache) {
            for each(var j:EffectView in i) {
                j.destroy();
            }
        }
        for each(var k:ShineEffectView in _shineCache) {
            k.destroy();
        }

        _viewCache  = null;
        _hitCache   = null;
        _defCache   = null;
        _shineCache = null;
    }

    /**
     * 取受击特效数据。
     *
     * <p>目标是无双小兵时走小兵表，否则优先 <code>customEffectVO</code>。克隆之后若震动的 <code>pow</code> 非 0，会写到 <code>shake.y</code>；<code>x</code> 和 <code>y</code> 都是 0 时把 <code>x</code> 改成 3。</p>
     *
     * @param hitvo 受击数据，同时作为缓存键。
     * @param target 受击目标；可省略。
     * @return 特效数据；表里没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var vo:EffectVO = manager.getHitEffectVOByHitVO(hit, target);
     * </listing>
     */
    public function getHitEffectVOByHitVO(hitvo:HitVO, target:IGameSprite = null):EffectVO {
        var cacheVO:EffectCacheVO = _hitCache[hitvo];

        // 增加小兵的打击效果判断
        var isMusouEnemy:Boolean = false;
        if (target && target is FighterMain) {
            var f:FighterMain = (
                    target as FighterMain
            );
            isMusouEnemy      = f.isMusouEnemy();
        }

        if (cacheVO) {
            if (isMusouEnemy && cacheVO.musouEnemy) {
                return cacheVO.musouEnemy;
            }
            if (!isMusouEnemy && cacheVO.normal) {
                return cacheVO.normal;
            }
        }

        var effect:EffectVO;
        if (isMusouEnemy) {
            effect = EffectModel.I.getMusouEnemyHitEffect(hitvo.hitType);
        }
        else if (hitvo.customEffectVO) {
            effect = hitvo.customEffectVO;
        }
        else {
            effect = EffectModel.I.getHitEffect(hitvo.hitType);
        }

        if (!effect) {
            _hitCache[hitvo] = null;
            return null;
        }

        effect = effect.clone(effect.className) as EffectVO;

        if (effect.shake) {
            if (effect.shake.pow != undefined && effect.shake.pow != 0) {
                effect.shake.y = effect.shake.pow;
            }
            if (effect.shake.x == 0 && effect.shake.y == 0) {
                effect.shake.x = 3;
            }

        }

        cacheVO = new EffectCacheVO();
        if (isMusouEnemy) {
            cacheVO.musouEnemy = effect;
        }
        else {
            cacheVO.normal = effect;
        }

        _hitCache[hitvo] = cacheVO;


        return effect;
    }

    /**
     * 取防御特效数据。
     *
     * <p>不改震动字段。缓存覆盖规则和受击特效相同。</p>
     *
     * @param hitvo 受击数据，同时作为缓存键。
     * @param defenseType 防御类型。
     * @param target 受击目标；可省略。
     * @return 特效数据；表里没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var vo:EffectVO = manager.getDefenseEffectVOByHitVO(hit, defenseType, target);
     * </listing>
     */
    public function getDefenseEffectVOByHitVO(hitvo:HitVO, defenseType:int, target:IGameSprite = null):EffectVO {
        var cacheVO:EffectCacheVO = _defCache[hitvo];

        // 增加小兵的打击效果判断
        var isMusouEnemy:Boolean = false;
        if (target && target is FighterMain) {
            var f:FighterMain = (
                    target as FighterMain
            );
            isMusouEnemy      = f.isMusouEnemy();
        }

        if (cacheVO) {
            if (isMusouEnemy && cacheVO.musouEnemy) {
                return cacheVO.musouEnemy;
            }
            if (!isMusouEnemy && cacheVO.normal) {
                return cacheVO.normal;
            }
        }


        var effect:EffectVO = isMusouEnemy ? EffectModel.I.getMusouEnemyDefenseEffect(hitvo.hitType, defenseType) :
                              EffectModel.I.getDefenseEffect(hitvo.hitType, defenseType);
        if (!effect) {
            _defCache[hitvo] = null;
            return null;
        }

        effect = effect.clone(effect.className) as EffectVO;

        cacheVO = new EffectCacheVO();
        if (isMusouEnemy) {
            cacheVO.musouEnemy = effect;
        }
        else {
            cacheVO.normal = effect;
        }

        _defCache[hitvo] = cacheVO;

        return effect;
    }


    /**
     * 取一个当前没在播的视图；没有就按数据类型新建。
     *
     * @param data 特效数据，同时作为缓存键。另一份克隆不会复用这里的视图。
     * @return 特效视图。
     * @example
     * <listing version="3.0">
     * var view:EffectView = manager.getEffectView(data);
     * </listing>
     */
    public function getEffectView(data:EffectVO):EffectView {
        var evs:Vector.<EffectView> = _viewCache[data];
        if (evs) {
            var l:int = evs.length;
            for (var i:int; i < l; i++) {
                if (!evs[i].isActive) {
                    return evs[i];
                }
            }
        }
        else {
            evs              = new Vector.<EffectView>();
            _viewCache[data] = evs;
        }

        var effectView:EffectView;

        if (data.isSpecial) {
            effectView = new SpecialEffectView(data);
        }
        else if (data.isBuff) {
            effectView = new BuffEffectView(data);
        }
        else if (data.isSteelHit) {
            effectView = new SteelHitEffect(data);
        }
        else {
            effectView = new EffectView(data);
        }

        evs.push(effectView);

        return effectView;
    }

    /**
     * 取一个当前没在播的闪光；没有就新建。
     *
     * @return 闪光视图。
     * @example
     * <listing version="3.0">
     * var shine:ShineEffectView = manager.getShine();
     * </listing>
     */
    public function getShine():ShineEffectView {
        var l:int = _shineCache.length;
        for (var i:int; i < l; i++) {
            if (!_shineCache[i].isActive) {
                return _shineCache[i];
            }
        }

        var se:ShineEffectView = new ShineEffectView();
        _shineCache.push(se);

        return se;
    }

}
}
