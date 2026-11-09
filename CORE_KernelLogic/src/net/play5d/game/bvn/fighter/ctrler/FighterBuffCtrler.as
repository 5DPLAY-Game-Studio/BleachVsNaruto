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

package net.play5d.game.bvn.fighter.ctrler {
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 给角色加一段时间的速度、攻击或防御变化。
 *
 * <p>同一个字段再次加上时，只改剩余时间，数值仍按最初记下的原值加上这次的增量，不会叠在当前值上。
 * 加速、加攻、加防会播特效。减速写入负数。减攻写入调用方传来的数，不再取反。减防写的字段是 <code>defense</code>，加防写的是 <code>defenseRate</code>。
 * 角色上没有这个字段时打日志并返回，特效也不播。销毁后再 <code>render</code> 会抛错。</p>
 *
 * @see FighterBuffVO
 */
public class FighterBuffCtrler {

    /**
     * 记下角色。
     *
     * @param fighter 被加状态的角色。
     * @example
     * <listing version="3.0">
     * var buff:FighterBuffCtrler = new FighterBuffCtrler(fighter);
     * </listing>
     */
    public function FighterBuffCtrler(fighter:FighterMain) {
        _fighter = fighter;
    }
    /** @private */
    private var _fighter:FighterMain;
    /** @private */
    private var _speed:Number      = 0;
    /** @private */
    private var _attackRate:Number = 0;
    /** @private */
    private var _buffObj:Object    = {};

    /**
     * 丢掉角色引用。已有的状态还留在表里。
     *
     * @example
     * <listing version="3.0">
     * buff.destroy();
     * </listing>
     */
    public function destroy():void {
        _fighter = null;
    }

    /**
     * 给 <code>speed</code> 加上增量，并播加速特效。
     *
     * @param upVal 增量。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.speedUp(2, 5);
     * </listing>
     */
    public function speedUp(upVal:Number = 0, hold:Number = 5):void {
        var buff:FighterBuffVO = addBuff('speed', upVal, hold);
        if (!buff) {
            return;
        }
        EffectCtrl.I.doEffectById('buff_effect_speed', _fighter.x, _fighter.y);
        EffectCtrl.I.doBuffEffect('buff_speed', _fighter, buff);
    }

    /**
     * 给 <code>attackRate</code> 加上增量，并播加攻特效。
     *
     * @param rateVal 增量。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.attackUp(0.2, 5);
     * </listing>
     */
    public function attackUp(rateVal:Number = 0, hold:Number = 5):void {
        var buff:FighterBuffVO = addBuff('attackRate', rateVal, hold);
        if (!buff) {
            return;
        }
        EffectCtrl.I.doEffectById('buff_effect_power', _fighter.x, _fighter.y);
        EffectCtrl.I.doBuffEffect('buff_power', _fighter, buff);
    }

    /**
     * 给 <code>defenseRate</code> 加上增量，并播加防特效。
     *
     * @param upVal 增量。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.defenseUp(0.2, 5);
     * </listing>
     */
    public function defenseUp(upVal:Number = 0, hold:Number = 5):void {
        var buff:FighterBuffVO = addBuff('defenseRate', upVal, hold);
        if (!buff) {
            return;
        }
        EffectCtrl.I.doEffectById('buff_effect_defense', _fighter.x, _fighter.y);
        EffectCtrl.I.doBuffEffect('buff_defense', _fighter, buff);
    }

    /**
     * 给 <code>speed</code> 加上增量的相反数。不播特效。
     *
     * @param downVal 要减掉的数。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.speedDown(1, 5);
     * </listing>
     */
    public function speedDown(downVal:Number = 0, hold:Number = 5):void {
        addBuff('speed', -downVal, hold);
    }

    /**
     * 给 <code>attackRate</code> 加上调用方传来的数。不取反，也不播特效。
     *
     * @param rateVal 写上去的增量。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.attackDown(-0.2, 5);
     * </listing>
     */
    public function attackDown(rateVal:Number = 0, hold:Number = 5):void {
        addBuff('attackRate', rateVal, hold);
    }

    /**
     * 给 <code>defense</code> 加上增量的相反数。不播特效。
     *
     * @param downVal 要减掉的数。默认 0。
     * @param hold 秒数。默认 5。
     * @example
     * <listing version="3.0">
     * buff.defenseDown(1, 5);
     * </listing>
     */
    public function defenseDown(downVal:Number = 0, hold:Number = 5):void {
        addBuff('defense', -downVal, hold);
    }

    /**
     * 推进全部状态。到期的写回原值并从表里去掉。
     *
     * <p>同一帧有多条到期时，循环里删除可能跳过后面的键。</p>
     *
     * @example
     * <listing version="3.0">
     * buff.render();
     * </listing>
     */
    public function render():void {
        for (var i:String in _buffObj) {
            var b:FighterBuffVO = _buffObj[i];
            if (b.render()) {
                _fighter[b.param] = b.resumeValue;
                delete _buffObj[i];
            }
        }
    }

    /** @private */
    private function addBuff(param:String, value:Number, hold:Number):FighterBuffVO {
        try {
            var buff:FighterBuffVO = _buffObj[param];
            if (!buff) {
                buff             = new FighterBuffVO(param, hold);
                _buffObj[param]  = buff;
                buff.resumeValue = _fighter[param];
            }
            else {
                buff.setHold(hold);
            }
            _fighter[param] = buff.resumeValue + value;
            return buff;
        }
        catch (e:Error) {
            GameLogger.error('fight', String(e));
            return null;
        }

        return null;
    }


}
}
