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
 * 角色事件
 */
public class FighterEvent extends Event {
    include '../../../../../../../include/_INCLUDE_.as';

    // 角色创建
    public static const BIRTH:String = 'BIRTH';

    // 发射子弹
    public static const FIRE_BULLET:String  = 'FIRE_BULLET';
    // 加入攻击对象
    public static const ADD_ATTACKER:String = 'ADD_ATTACKER';
    // 加入特效对象
    public static const ADD_EFFECT:String   = 'ADD_EFFECT';

    // 攻击到目标
    public static const HIT_TARGET:String  = 'HIT_TARGET';
    // 被打
    public static const HURT:String        = 'HURT';
    // 从被打状态恢复
    public static const HURT_RESUME:String = 'HURT_RESUME';
    // 被击倒
    public static const HURT_DOWN:String   = 'HURT_DOWN';

    // 防御
    public static const DEFENSE:String = 'DEFENSE';
    // 恢复站立
    public static const IDLE:String    = 'IDLE';

    // 死亡
    public static const DIE:String  = 'DIE';
    // 死透（死亡&击倒）
    public static const DEAD:String = 'DEAD';

    // 执行动作
    public static const DO_ACTION:String  = 'DO_ACTION';
    // 执行特殊
    public static const DO_SPECIAL:String = 'DO_SPECIAL';

    /**
     * 构造方法
     * @param type 事件的类型
     * @param bubbles 事件是否为冒泡事件
     * @param cancelable 是否可以阻止与事件相关联的行为
     */
    public function FighterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    // 传递参数
    public var params:Object;
    // 目标对象
    public var fighter:BaseGameSprite;
}
}
