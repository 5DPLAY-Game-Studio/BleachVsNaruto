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

package net.play5d.game.bvn.fighter.events {
import flash.events.Event;

import net.play5d.game.bvn.interfaces.BaseGameSprite;

/**
 * 角色出生、攻击、受击和死亡事件。
 *
 * <p>没有覆写 <code>clone</code>。重派后 <code>fighter</code> 和 <code>params</code> 都是 <code>null</code>。
 * 构造时也不写这两个字段。</p>
 *
 * @see flash.events.Event
 * @see FighterEventDispatcher
 */
public class FighterEvent extends Event {

    /**
     * 角色创建。
     *
     * @eventType BIRTH
     */
    public static const BIRTH:String = 'BIRTH';

    /**
     * 发射子弹。
     *
     * @eventType FIRE_BULLET
     */
    public static const FIRE_BULLET:String  = 'FIRE_BULLET';
    /**
     * 加入攻击对象。
     *
     * @eventType ADD_ATTACKER
     */
    public static const ADD_ATTACKER:String = 'ADD_ATTACKER';
    /**
     * 加入特效对象。
     *
     * @eventType ADD_EFFECT
     */
    public static const ADD_EFFECT:String   = 'ADD_EFFECT';

    /**
     * 攻击到目标。
     *
     * @eventType HIT_TARGET
     */
    public static const HIT_TARGET:String  = 'HIT_TARGET';
    /**
     * 被打。
     *
     * @eventType HURT
     */
    public static const HURT:String        = 'HURT';
    /**
     * 从被打状态恢复。
     *
     * @eventType HURT_RESUME
     */
    public static const HURT_RESUME:String = 'HURT_RESUME';
    /**
     * 被击倒。
     *
     * @eventType HURT_DOWN
     */
    public static const HURT_DOWN:String   = 'HURT_DOWN';

    /**
     * 防御。
     *
     * @eventType DEFENSE
     */
    public static const DEFENSE:String = 'DEFENSE';
    /**
     * 恢复站立。
     *
     * @eventType IDLE
     */
    public static const IDLE:String    = 'IDLE';

    /**
     * 死亡。
     *
     * @eventType DIE
     */
    public static const DIE:String  = 'DIE';
    /**
     * 死透，死亡并且击倒。
     *
     * @eventType DEAD
     */
    public static const DEAD:String = 'DEAD';

    /**
     * 执行动作。
     *
     * @eventType DO_ACTION
     */
    public static const DO_ACTION:String  = 'DO_ACTION';
    /**
     * 执行特殊。
     *
     * @eventType DO_SPECIAL
     */
    public static const DO_SPECIAL:String = 'DO_SPECIAL';

    /**
     * 用事件名构造。附加字段保持 <code>null</code>。
     *
     * @param type 事件名。为空时父类构造抛错。
     * @param bubbles 是否冒泡。默认 <code>false</code>。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var e:FighterEvent = new FighterEvent(FighterEvent.DIE);
     * </listing>
     */
    public function FighterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    /**
     * 附加参数。
     *
     * @default null
     */
    public var params:Object;
    /**
     * 发出这次事件的角色。
     *
     * @default null
     */
    public var fighter:BaseGameSprite;
}
}
