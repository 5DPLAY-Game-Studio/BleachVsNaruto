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
import net.play5d.game.bvn.data.fighter.FighterHurtType;
import net.play5d.game.bvn.data.vos.EffectVO;

import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 一次攻击的威力、击退和受击。
 *
 * <p>构造时如果类型是斩击，并且僵直小于 100 毫秒，会改成 100。
 * 带了自定义特效时会立刻做帧缓存，类名对不上会抛错。
 * 必杀和技能只看 id 里有没有那几个字母，空 id 返回 <code>false</code>。
 * 伤害按 <code>(power + power * powerAdd / 100) * powerRate</code> 取整。
 * 弱打击只在主人是无双小兵、并且这次不是重击或击飞时成立。</p>
 *
 * @see FighterHitModel
 */
public class HitVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 用对象填写同名字段。对象为空时只留默认值。
     *
     * @param obj 字段来源。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hit:HitVO = new HitVO(obj);
     * </listing>
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

    /**
     * 攻击 id。
     *
     * @default null
     */
    public var id:String         = null;
    /**
     * 发出这次攻击的对象。
     *
     * @default null
     */
    public var owner:IGameSprite = null;

    /**
     * 基础威力。
     *
     * @default 0
     */
    public var power:Number     = 0;
    /**
     * 威力百分比加成。
     *
     * @default 0
     */
    public var powerAdd:Number  = 0;
    /**
     * 威力倍率。
     *
     * @default 1
     */
    public var powerRate:Number = 1;

    /**
     * 攻击类型。默认是斩击。
     *
     * @default 1
     */
    public var hitType:int = HitType.KAN;

    /**
     * 是否破防。
     *
     * @default false
     */
    public var isBreakDef:Boolean = false;

    /**
     * 击退速度。
     *
     * @default 0
     */
    public var hitx:Number = 0;
    /**
     * 击飞速度。
     *
     * @default 0
     */
    public var hity:Number = 0;

    /**
     * 僵直毫秒。斩击且小于 100 时，构造会改成 100。
     *
     * @default 300
     */
    public var hurtTime:Number = 300;
    /**
     * 受击类型。0 是被打，1 是击飞。
     *
     * @default 0
     */
    public var hurtType:int    = FighterHurtType.HURT;

    /**
     * 受击慢放毫秒。
     *
     * @default 0
     */
    public var slowDown:Number = 0;

    /**
     * 同向时是否无视防御。
     *
     * @default true
     */
    public var checkDirect:Boolean = true;

    /**
     * 当前攻击范围。
     *
     * @default null
     */
    public var currentArea:Rectangle = null;

    /**
     * 命中后是否把对方设成镜头焦点。
     *
     * @default false
     */
    public var focusTarget:Boolean = false;

    /**
     * 自定义打击效果参数。
     *
     * @default null
     */
    public var customEffect:Object     = null;
    /**
     * 由自定义参数建成的特效。构造前为 <code>null</code>。
     *
     * @default null
     */
    public var customEffectVO:EffectVO = null;

    /**
     * 对方吃下这次伤害后是否仍受重力。
     *
     * @default true
     */
    public var targetApplyG:Boolean = true;

    /**
     * id 里是否含有 <code>bs</code>。空 id 为 <code>false</code>。
     *
     * @return 含有时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var bisha:Boolean = hit.isBisha();
     * </listing>
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
     * id 里是否含有 <code>tz</code>、<code>kj</code>、<code>zh</code> 或 <code>sh</code>。空 id 为 <code>false</code>。
     *
     * @return 含有时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var skill:Boolean = hit.isSkill();
     * </listing>
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
     * 是否为投技。类型是投，并且破防，才为 <code>true</code>。
     *
     * @return 两者都成立时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var caught:Boolean = hit.isCatch();
     * </listing>
     */
    public function isCatch():Boolean {
        return hitType == HitType.CATCH && isBreakDef;
    }

    /**
     * 按威力和倍率算出的整数伤害。
     *
     * @return 截成整数后的伤害。
     * @example
     * <listing version="3.0">
     * var dmg:int = hit.getDamage();
     * </listing>
     */
    public function getDamage():int {
        var powAdd:Number = power * (powerAdd / 100);

        return (power + powAdd) * powerRate;
    }

    /**
     * 这次是否算弱打击。没有主人、重击或击飞时为 <code>false</code>。
     *
     * @return 主人是无双小兵时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var weak:Boolean = hit.isWeakHit();
     * </listing>
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

    /** @private */
    private static function checkEnemyFighter(fighter:FighterMain):Boolean {
        if (!fighter || !fighter.musouEnemyData) {
            return false;
        }

        return !fighter.musouEnemyData.isBoss;
    }

}
}
