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

package net.play5d.game.bvn.fighter {
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 角色当前状态，以及这一帧允许接的动作名。
 *
 * <p><code>clearState</code> 只清布尔状态，不清 <code>airMove</code>、跳跃次数和冷却。
 * <code>clearAction</code> 清动作名并把必杀气量恢复默认，但不清 <code>banKaiW</code>、<code>banKaiS</code>、跳跃次数和冷却。
 * 冷却用 <code>time / FPS_GAME</code> 当成剩余帧。存进去的值是 0 时，<code>CDOK</code> 立刻为 <code>true</code>。
 * 同一帧多条冷却到期时，循环里删除可能跳过后面的键。</p>
 */
public class FighterAction {

    /**
     * 是否在移动。
     *
     * @default false
     */
    public var isMoving:Boolean;
    /**
     * 是否在跳。
     *
     * @default false
     */
    public var isJumping:Boolean;
    /**
     * 是否在防御。
     *
     * @default false
     */
    public var isDefenseing:Boolean;
    /**
     * 是否在冲。
     *
     * @default false
     */
    public var isDashing:Boolean;
    /**
     * 是否在被打。
     *
     * @default false
     */
    public var isHurting:Boolean;
    /**
     * 是否在击飞。
     *
     * @default false
     */
    public var isHurtFlying:Boolean;
    /**
     * 是否正防住攻击。
     *
     * @default false
     */
    public var isDefenseHitting:Boolean;
    /**
     * 是否允许空中移动。<code>clearState</code> 不清它。
     *
     * @default false
     */
    public var airMove:Boolean;
    /**
     * 落地要接的动作名。
     *
     * @default null
     */
    public var touchFloor:String;
    /**
     * 落地是否打断当前动作。
     *
     * @default false
     */
    public var touchFloorBreakAct:Boolean = false;
    /**
     * 命中目标时要接的动作名。
     *
     * @default null
     */
    public var hitTarget:String;
    /**
     * 判定目标用的检查名。
     *
     * @default null
     */
    public var hitTargetChecker:String;
    /**
     * 向左移动的动作名。
     *
     * @default null
     */
    public var moveLeft:String;
    /**
     * 向右移动的动作名。
     *
     * @default null
     */
    public var moveRight:String;
    /**
     * 防御动作名。
     *
     * @default null
     */
    public var defense:String;
    /**
     * 跳跃动作名。
     *
     * @default null
     */
    public var jump:String;
    /**
     * 小跳动作名。
     *
     * @default null
     */
    public var jumpQuick:String;
    /**
     * 从空中落下的动作名。
     *
     * @default null
     */
    public var jumpDown:String;
    /**
     * 冲刺动作名。
     *
     * @default null
     */
    public var dash:String;
    /**
     * 普攻动作名。
     *
     * @default null
     */
    public var attack:String;
    /**
     * 技能 1 动作名。
     *
     * @default null
     */
    public var skill1:String;
    /**
     * 技能 2 动作名。
     *
     * @default null
     */
    public var skill2:String;
    /**
     * 招式 1 动作名。
     *
     * @default null
     */
    public var zhao1:String;
    /**
     * 招式 2 动作名。
     *
     * @default null
     */
    public var zhao2:String;
    /**
     * 招式 3 动作名。
     *
     * @default null
     */
    public var zhao3:String;
    /**
     * 投技 1 动作名。
     *
     * @default null
     */
    public var catch1:String;
    /**
     * 投技 2 动作名。
     *
     * @default null
     */
    public var catch2:String;
    /**
     * 必杀动作名。
     *
     * @default null
     */
    public var bisha:String;
    /**
     * 上必杀动作名。
     *
     * @default null
     */
    public var bishaUP:String;
    /**
     * 超必杀动作名。
     *
     * @default null
     */
    public var bishaSUPER:String;
    /**
     * 受击动作名。
     *
     * @default null
     */
    public var hurtAction:String;
    /**
     * 卍解动作名。
     *
     * @default null
     */
    public var banKai:String;
    /**
     * 前卍解动作名。<code>clearAction</code> 不清它。
     *
     * @default null
     */
    public var banKaiW:String;
    /**
     * 后卍解动作名。<code>clearAction</code> 不清它。
     *
     * @default null
     */
    public var banKaiS:String;
    /**
     * 空中普攻动作名。
     *
     * @default null
     */
    public var attackAIR:String;
    /**
     * 空中技能动作名。
     *
     * @default null
     */
    public var skillAIR:String;
    /**
     * 空中必杀动作名。
     *
     * @default null
     */
    public var bishaAIR:String;
    /**
     * 空中已命中次数。清空动作时留着。
     *
     * @default 0
     */
    public var airHitTimes:int;
    /**
     * 已跳跃次数。清空动作时留着。
     *
     * @default 0
     */
    public var jumpTimes:int;
    /**
     * 必杀消耗的气。
     *
     * @default 100
     */
    public var bishaQi:int                = 100;
    /**
     * 上必杀消耗的气。
     *
     * @default 100
     */
    public var bishaUPQi:int              = 100;
    /**
     * 超必杀消耗的气。
     *
     * @default 300
     */
    public var bishaSUPERQi:int           = 300;
    /**
     * 空中必杀消耗的气。
     *
     * @default 100
     */
    public var bishaAIRQi:int             = 100;
    /** @private */
    private var _cdObj:Object             = {};

    /**
     * 先清状态，再清动作。冷却、跳跃次数和前后卍解还留着。
     *
     * @example
     * <listing version="3.0">
     * action.clear();
     * </listing>
     */
    public function clear():void {
        clearState();
        clearAction();
    }

    /**
     * 把移动、跳跃、防御、冲刺和受击标记清成 <code>false</code>。
     *
     * @example
     * <listing version="3.0">
     * action.clearState();
     * </listing>
     */
    public function clearState():void {
        isMoving           = false;
        isJumping          = false;
        isDefenseing       = false;
        isDashing          = false;
        isHurting          = false;
        isHurtFlying       = false;
        isDefenseHitting   = false;
        touchFloorBreakAct = false;

    }

    /**
     * 清掉动作名，并把必杀气量恢复默认。空中移动清成 <code>false</code>。
     *
     * @example
     * <listing version="3.0">
     * action.clearAction();
     * </listing>
     */
    public function clearAction():void {
        hitTarget        = null;
        hitTargetChecker = null;

        moveLeft  = null;
        moveRight = null;

        defense = null;

        jump      = null;
        jumpQuick = null;
        jumpDown  = null;

        dash = null;

        attack = null;

        skill1 = null;
        skill2 = null;

        zhao1 = null;
        zhao2 = null;
        zhao3 = null;

        catch1 = null;
        catch2 = null;

        bisha      = null;
        bishaUP    = null;
        bishaSUPER = null;

        bishaQi      = 100;
        bishaUPQi    = 100;
        bishaAIRQi   = 100;
        bishaSUPERQi = 300;

        hurtAction = null;

        banKai = null;

        attackAIR = null;
        skillAIR  = null;
        bishaAIR  = null;

        touchFloor = null;

        airMove = false;
    }

    /**
     * 给全部冷却减一帧，减到 0 及以下就删掉。
     *
     * @example
     * <listing version="3.0">
     * action.render();
     * </listing>
     */
    public function render():void {
        for (var i:String in _cdObj) {
            var v:int = _cdObj[i];
            if ((
                        _cdObj[i] = --v
                ) <= 0) {
                delete _cdObj[i];
            }
        }
    }

    /**
     * 记下冷却。实际帧数是 <code>time / FPS_GAME</code>。
     *
     * @param id 冷却 id。
     * @param time 除帧率之前的数。
     * @example
     * <listing version="3.0">
     * action.setCD(id, 30);
     * </listing>
     */
    public function setCD(id:String, time:int):void {
        _cdObj[id] = time / GameConfig.FPS_GAME;
        GameLogger.debug('fight', 'setCD ' + id + ' ' + _cdObj[id]);
    }

    /**
     * 这个冷却是否已经没了。没有记录，或记录是 0，都为 <code>true</code>。
     *
     * @param id 冷却 id。
     * @return 可以再放时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ready:Boolean = action.CDOK(id);
     * </listing>
     */
    public function CDOK(id:String):Boolean {
        return !_cdObj[id];
    }
}
}
