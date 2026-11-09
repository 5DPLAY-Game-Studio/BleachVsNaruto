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

package net.play5d.game.bvn.utils {
import flash.events.Event;

/**
 * 单指或双指拖动事件。不冒泡，也不能取消。
 *
 * <p>继承的 <code>clone</code> 只返回普通 <code>Event</code>，这里的位移和起止点不会带上。未赋值的 <code>deltaX</code>、<code>deltaY</code>、<code>delta</code> 是 NaN。</p>
 *
 * @see flash.events.Event#clone()
 */
public class TouchMoveEvent extends Event {

    /**
     * 按下。
     *
     * @eventType EVENT_TOUCH_BEGIN
     * @default EVENT_TOUCH_BEGIN
     */
    public static const TOUCH_BEGIN:String = 'EVENT_TOUCH_BEGIN';
    /**
     * 拖动。
     *
     * @eventType EVENT_TOUCH_MOVE
     * @default EVENT_TOUCH_MOVE
     */
    public static const TOUCH_MOVE:String  = 'EVENT_TOUCH_MOVE';
    /**
     * 抬起。
     *
     * @eventType EVENT_TOUCH_END
     * @default EVENT_TOUCH_END
     */
    public static const TOUCH_END:String   = 'EVENT_TOUCH_END';

    /**
     * 创建事件。类型为 null 时抛错。
     *
     * @param type 事件类型。
     * @throws Error 类型为 null 时。
     */
    public function TouchMoveEvent(type:String) {
        super(type, false, false);
    }
    /**
     * 本次移动的横向位移。单指拖动时才写。未写时是 NaN。
     */
    public var deltaX:Number;
    /**
     * 本次移动的纵向位移。单指拖动时才写。未写时是 NaN。
     */
    public var deltaY:Number;
    /**
     * 双指间距变化。双指移动时才写。未写时是 NaN。
     */
    public var delta:Number;
    /**
     * 按下时的舞台横坐标。
     *
     * @default 0
     */
    public var startX:Number    = 0;
    /**
     * 按下时的舞台纵坐标。
     *
     * @default 0
     */
    public var startY:Number    = 0;
    /**
     * 抬起时的舞台横坐标。
     *
     * @default 0
     */
    public var endX:Number      = 0;
    /**
     * 抬起时的舞台纵坐标。
     *
     * @default 0
     */
    public var endY:Number      = 0;
    /**
     * 从按下到抬起的横向距离，是终点减起点。
     *
     * @default 0
     */
    public var distanceX:Number = 0;
    /**
     * 从按下到抬起的纵向距离，是终点减起点。
     *
     * @default 0
     */
    public var distanceY:Number = 0;
}
}
