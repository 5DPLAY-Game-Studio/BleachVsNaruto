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

package net.play5d.game.bvn.fighter.models {
import flash.geom.Rectangle;

import net.play5d.game.bvn.data.HitType;
import net.play5d.game.bvn.data.vos.EffectVO;

import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 攻击值对象
 */
public class HitVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    /**
     * 攻击值对象
     *
     * @param obj 对象参数
     */
    public function HitVO(obj:Object = null) {
        if (obj) {
            KyoUtils.setValueByObject(this, obj);
        }

        if (hitType == HitType.KAN) {
            if (hurtTime < 100) {
                hurtTime = 100;
            }
        }

        // 如果包含自定义效果，则执行
        if (customEffect) {
            customEffectVO = new EffectVO(null, customEffect);
            customEffectVO.cacheBitmapData();
        }
    }

    // 攻击 id
    public var id:String         = null;
    // 所有者
    public var owner:IGameSprite = null;

    // 攻击力
    public var power:Number     = 0;
    // 叠加攻击力
    public var powerAdd:Number  = 0;
    // 攻击倍数
    public var powerRate:Number = 1;

    // 攻击类型
    public var hitType:int = HitType.KAN;

    // 是否造成破防效果
    public var isBreakDef:Boolean = false;

    // 击退速度
    public var hitx:Number = 0;
    // 击飞速度
    public var hity:Number = 0;

    // 僵直时间（毫秒）
    public var hurtTime:Number = 300;
    // 受击类型（0 被打， 1 击飞）
    public var hurtType:int    = 0;

    // 受击后的慢放时间（毫秒）
    public var slowDown:Number = 0;

    // 是否检查方向，若为 true，则当攻击方与被攻击方同向时，无视防御
    public var checkDirect:Boolean = true;

//    // 攻击范围缓存
//    private var _hitAreaCache:Object = {};

    // 攻击范围
    public var currentArea:Rectangle = null;

    // 攻击到对方时，设置对方为焦点
    public var focusTarget:Boolean = false;

    // 自定义击打效果参数
    // {customMcCls: mc_cls, customSndCls: snd_cls, ...}
    public var customEffect:Object     = null;
    // 自定义打击效果 EffectVO
    public var customEffectVO:EffectVO = null;

    // 对方受到此次伤害后，是否受到重力效果
    public var targetApplyG:Boolean = true;

//    // 克隆键值
//    private var _cloneKey:Array = [
//        'id', 'owner', 'power', 'powerAdd', 'powerRate', 'hitType', 'isBreakDef', 'hitx', 'hity', 'hurtTime',
//        'hurtType', 'currentArea', 'checkDirect', 'slowDown', 'focusTarget'
//    ];
//
//    /**
//     * 克隆自身
//     *
//     * @return 返回自身实例的克隆对象
//     */
//    public function clone():HitVO {
//        var hv:HitVO = new HitVO();
//        KyoUtils.cloneValue(hv, this, _cloneKey);
//
//        return hv;
//    }

    /**
     * 是否为必杀
     *
     * @return 是否为必杀
     */
    public function isBisha():Boolean {
        if (id == null) {
            return false;
        }

        return id.indexOf('bs') != -1 ||
               id.indexOf('sbs') != -1 ||
               id.indexOf('cbs') != -1 ||
               id.indexOf('kbs') != -1;
    }

    /**
     * 是否为普通技能
     *
     * @return 是否为普通技能
     */
    public function isSkill():Boolean {
        if (id == null) {
            return false;
        }

        return id.indexOf('tz') != -1 ||
               id.indexOf('kj') != -1 ||
               id.indexOf('zh') != -1 ||
               id.indexOf('sh') != -1;
    }

    /**
     * 是否为摔技
     *
     * @return 是否为摔技
     */
    public function isCatch():Boolean {
        return hitType == HitType.CATCH && isBreakDef;
    }

    /**
     * 获取当前攻击伤害
     *
     * @return 当前攻击伤害
     */
    public function getDamage():int {
        var powAdd:Number = power * (powerAdd / 100);

        return (power + powAdd) * powerRate;
    }

    /**
     * 是否为弱打击伤害
     *
     * @return 是否为弱打击伤害
     */
    public function isWeakHit():Boolean {
        if (!owner) {
            return false;
        }

        if (HitType.isHeavy(hitType) || hurtType == 1) {
            return false;
        }

        if (owner is FighterMain) {
            return checkEnemyFighter(
                    owner as FighterMain
            );
        }
        if (owner is Bullet) {
            return checkEnemyFighter(
                    (owner as Bullet).owner as FighterMain
            );
        }
        if (owner is FighterAttacker) {
            return checkEnemyFighter(
                    (owner as FighterAttacker).getOwner() as FighterMain
            );
        }

        return false;
    }

    /**
     * 检查敌人 FighterMain 是否不为 Boss
     *
     * @param fighter 敌人 FighterMain
     * @return 敌人 FighterMain 是否不为 Boss
     */
    private static function checkEnemyFighter(fighter:FighterMain):Boolean {
        if (!fighter || !fighter.mosouEnemyData) {
            return false;
        }

        return !fighter.mosouEnemyData.isBoss;
    }

}
}
