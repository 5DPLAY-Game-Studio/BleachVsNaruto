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

package net.play5d.game.bvn.debug {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import net.play5d.game.bvn.utils.DebugSprite;

/**
 * 给显示对象套一个可拖动的黄框，松手后把框的位置写回对象。
 *
 * <p><code>enabled</code> 固定为 <code>true</code>，方法开头的开关判断不会提前返回。
 * 同一个对象再调一次会先拆掉上一只框。对象没有父级、又没传入容器时只打日志并返回。
 * 按下时框提到父级最前，透明度变成 0.7；松开后透明度变成 0.1，并把框的 <code>x</code>、<code>y</code> 写到对象上。</p>
 *
 * @see net.play5d.game.bvn.utils.DebugSprite
 */
public class DebugUtil {

    /** @private */
    private static const map:Dictionary = new Dictionary();

    /**
     * 是否允许套框。当前固定为 <code>true</code>。
     *
     * @default true
     */
    public static const enabled:Boolean = true;

    /**
     * 在容器里放一只黄框，拖完后把位置写回对象。
     *
     * <p><code>d</code> 为空时抛错。没传容器时用对象自己的父级。</p>
     *
     * @param d 要定位的显示对象。
     * @param container 黄框的父级。默认 <code>null</code>，改用 <code>d.parent</code>。
     * @example
     * <listing version="3.0">
     * DebugUtil.debugPosition(sprite);
     * </listing>
     */
    public static function debugPosition(d:DisplayObject, container:DisplayObjectContainer = null):void {
        if (!enabled) {
            return;
        }

        if (map[d]) {
            (
                    map[d] as DebugSprite
            ).destroy();
        }

        if (!d.parent && !container) {
            TraceLang('debug_util.debug_position');
            return;
        }

        container ||= d.parent;

        var box:DebugSprite = new DebugSprite(0xffff00, d);
        box.alpha           = 0.3;
        container.addChild(box);

        box.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);

        map[d] = box;

        function startDrag(e:MouseEvent):void {
            var t:DebugSprite = e.currentTarget as DebugSprite;
            if (t.parent) {
                t.parent.addChild(t);
            }

            t.alpha = 0.7;
            t.startDrag(false);
            t.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
        }

        function stopDrag(e:MouseEvent):void {
            var t:DebugSprite = e.currentTarget as DebugSprite;
            t.alpha           = 0.1;

            t.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);

            t.stopDrag();
            t.applySet();
        }

    }

}
}
