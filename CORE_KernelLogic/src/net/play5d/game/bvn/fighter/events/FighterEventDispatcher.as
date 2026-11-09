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
import flash.events.EventDispatcher;

import net.play5d.game.bvn.interfaces.BaseGameSprite;

/**
 * 角色事件的静态总线。
 *
 * <p>每种事件名只在表里留最后一次加进来的监听。总线本身可以同时挂着更早的函数。
 * <code>hasEventListener</code> 只看这张表，不看总线。
 * <code>removeEventListener</code> 会删掉该事件名的表项，即使传入的函数不是最后那次。
 * <code>removeAllListeners</code> 只从总线上摘掉表里剩下的函数，同一种事件名更早加上的函数还在。</p>
 *
 * @see FighterEvent
 */
public class FighterEventDispatcher {

    /** @private */
    private static var _dispatcher:EventDispatcher = new EventDispatcher();

    /** @private */
    private static var _addedEvents:Object = {};

    /**
     * 这种事件名是否还留在表里。
     *
     * @param type 事件名。
     * @return 表里有记录时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var on:Boolean = FighterEventDispatcher.hasEventListener(FighterEvent.DIE);
     * </listing>
     */
    public static function hasEventListener(type:String):Boolean {
        return _addedEvents[type] != null;
    }

    /**
     * 监听一种角色事件，并记下这次的函数。
     *
     * <p>默认强引用。监听函数收到的是 <code>FighterEvent</code>。</p>
     *
     * @param type 事件名。
     * @param listener 监听函数。为空时抛错。
     * @param useCapture 是否捕获。默认 <code>false</code>。
     * @param priority 优先级。默认 0。
     * @param useWeakReference 是否弱引用。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * FighterEventDispatcher.addEventListener(FighterEvent.DIE, onDie);
     * </listing>
     */
    public static function addEventListener(
            type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
            useWeakReference:Boolean = false
    ):void {
        _addedEvents[type] = listener;
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * 从总线移除这个函数，并删掉该事件名的表项。
     *
     * @param type 事件名。
     * @param listener 要从总线上摘掉的函数。
     * @param useCapture 必须和添加时一致。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * FighterEventDispatcher.removeEventListener(FighterEvent.DIE, onDie);
     * </listing>
     */
    public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        delete _addedEvents[type];
        _dispatcher.removeEventListener(type, listener, useCapture);
    }

    /**
     * 摘掉表里每种事件名最后记下的函数，然后清空表。
     *
     * @example
     * <listing version="3.0">
     * FighterEventDispatcher.removeAllListeners();
     * </listing>
     */
    public static function removeAllListeners():void {
        for (var i:String in _addedEvents) {
            _dispatcher.removeEventListener(i, _addedEvents[i]);
        }
        _addedEvents = {};
    }

    /**
     * 派发一条不冒泡的角色事件。
     *
     * <p><code>event</code> 为空时构造抛错。返回值被丢掉。</p>
     *
     * @param fighter 写到事件上的角色。可以是 <code>null</code>。
     * @param event 事件名。
     * @param params 附加参数。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * FighterEventDispatcher.dispatchEvent(fighter, FighterEvent.HIT_TARGET, params);
     * </listing>
     */
    public static function dispatchEvent(fighter:BaseGameSprite, event:String, params:Object = null):void {
        var fv:FighterEvent = new FighterEvent(event, false, false);
        fv.fighter          = fighter;
        fv.params           = params;
        _dispatcher.dispatchEvent(fv);
    }

}
}
