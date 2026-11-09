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

package net.play5d.game.bvn.ctrler {
import flash.events.Event;

/**
 * 游戏按键事件。
 *
 * <p>类型字符串是本类的 <code>KEY_DOWN</code> / <code>KEY_UP</code>，不是 <code>KeyboardEvent</code>。
 * 没有覆写 <code>clone</code>，再派发时 <code>keyCode</code> 和 <code>justDown</code> 会丢。</p>
 *
 * @see flash.events.Event
 */
public class KeyEvent extends Event {

    /**
     * <code>keyDown</code> 的类型字符串。
     *
     * @eventType KEY_DOWN
     * @default KEY_DOWN
     */
    public static const KEY_DOWN:String = 'KEY_DOWN';
    /**
     * <code>keyUp</code> 的类型字符串。
     *
     * @eventType KEY_UP
     * @default KEY_UP
     */
    public static const KEY_UP:String   = 'KEY_UP';

    /**
     * 构造按键事件。
     *
     * @param type <code>KEY_DOWN</code> 或 <code>KEY_UP</code>。
     * @param keyCode 键值。
     * @param justDown 是否本帧刚按下。默认 <code>false</code>。
     * @param bubbles 是否冒泡。默认 <code>false</code>。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var e:KeyEvent = new KeyEvent(KeyEvent.KEY_DOWN, 65, true);
     * </listing>
     */
    public function KeyEvent(
            type:String, keyCode:uint, justDown:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false) {
        this.keyCode = keyCode;
        this.justDown = justDown;
        super(type, bubbles, cancelable);
    }

    /**
     * 键值。
     *
     * @default 0
     */
    public var keyCode:uint;
    /**
     * 是否本帧刚按下。
     *
     * @default false
     */
    public var justDown:Boolean;
}
}
