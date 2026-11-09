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

package net.play5d.game.bvn.events {
import flash.events.Event;

/**
 * 带一个自定义参数的事件。
 *
 * <p>工程里没有构造它的代码。没有覆写 <code>clone</code>，重派后新事件上的 <code>param</code> 是 <code>null</code>。</p>
 *
 * @see flash.events.Event
 */
public class ParamEvent extends Event {

    /**
     * 记下参数。赋值发生在调用父类构造之前。
     *
     * @param type 事件名。为空时父类构造抛错。
     * @param param 随事件带走的值。
     * @param bubbles 是否冒泡。默认 <code>false</code>。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var e:ParamEvent = new ParamEvent('CUSTOM', value);
     * </listing>
     */
    public function ParamEvent(type:String, param:*, bubbles:Boolean = false, cancelable:Boolean = false) {
        this.param = param;
        super(type, bubbles, cancelable);
    }
    /**
     * 构造时写入的参数。
     *
     * @default null
     */
    public var param:*;
}
}
