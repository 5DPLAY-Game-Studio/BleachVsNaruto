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
import flash.display.Stage;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * 游戏渲染
 */
public class GameRender {
    include '../../../../../../include/_INCLUDE_.as';

    // 是否渲染
    public static var isRender:Boolean = true;

    // 先于主渲染之前渲染
    private static var _beforeFuncs:Vector.<Function>;
    // 主渲染
    private static var _funcs:Dictionary = new Dictionary();
    // 后于主渲染之后渲染
    private static var _afterFuncs:Vector.<Function>;

    /**
     * 初始化
     *
     * @param stage 游戏舞台
     */
    public static function initialize(stage:Stage):void {
        stage.addEventListener(Event.ENTER_FRAME, render);
    }

    /**
     * 添加一个先于主渲染之前渲染的函数
     *
     * @param func 渲染函数
     */
    public static function addBefore(func:Function):void {
        if (func == null) {
            return;
        }

        _beforeFuncs ||= new Vector.<Function>();

        var index:int = _beforeFuncs.indexOf(func);
        if (index == -1) {
            _beforeFuncs.push(func);
        }
    }

    /**
     * 移除一个先于主渲染之前渲染的函数
     *
     * @param func 渲染函数
     */
    public static function removeBefore(func:Function):void {
        if (func == null || !_beforeFuncs) {
            return;
        }

        var index:int = _beforeFuncs.indexOf(func);
        if (index != -1) {
            _beforeFuncs.splice(index, 1);
        }
    }

    /**
     * 添加一个主渲染函数
     *
     * @param func 渲染函数
     * @param owner 渲染函数归属
     */
    public static function add(func:Function, owner:* = null):void {
        owner ||= 'anyone';

        if (_funcs[owner] && _funcs[owner].indexOf(func) != -1) {
            return;
        }

        _funcs[owner] ||= new Vector.<Function>();
        _funcs[owner].push(func);
    }

    /**
     * 移除一个主渲染函数
     *
     * @param func 渲染函数
     * @param owner 渲染函数归属
     */
    public static function remove(func:Function, owner:* = null):void {
        owner ||= 'anyone';

        if (!_funcs[owner]) {
            return;
        }

        var index:int = _funcs[owner].indexOf(func);
        if (index != -1) {
            _funcs[owner].splice(index, 1);
        }
    }

    /**
     * 添加一个后于主渲染之后渲染的函数
     *
     * @param func 渲染函数
     */
    public static function addAfter(func:Function):void {
        if (func == null) {
            return;
        }

        _afterFuncs ||= new Vector.<Function>();

        var index:int = _afterFuncs.indexOf(func);
        if (index == -1) {
            _afterFuncs.push(func);
        }
    }

    /**
     * 移除一个后于主渲染之后渲染的函数
     *
     * @param func 渲染函数
     */
    public static function removeAfter(func:Function):void {
        if (!func || !_afterFuncs) {
            return;
        }

        var index:int = _afterFuncs.indexOf(func);
        if (index != -1) {
            _afterFuncs.splice(index, 1);
        }
    }

    private static function render(e:Event):void {
        if (!isRender) {
            return;
        }

        var i:int, length:int;
        var func:Function;
        if (_beforeFuncs) {
            length = _beforeFuncs.length;
            for (i = 0; i < length; i++) {
                if (i > _beforeFuncs.length - 1) {
                    break;
                }

                func = _beforeFuncs[i] as Function;
                if (func != null) {
                    func();
                }
            }
        }


        for each (var funcs:Vector.<Function> in _funcs) {
            length = funcs.length;
            for (i = 0; i < length; i++) {
                if (i > funcs.length - 1) {
                    break;
                }

                func = funcs[i] as Function;
                if (func != null) {
                    func();
                }
            }
        }

        if (_afterFuncs) {
            length = _afterFuncs.length;
            for (i = 0; i < length; i++) {
                if (i > _afterFuncs.length - 1) {
                    break;
                }

                func = _afterFuncs[i] as Function;
                if (func != null) {
                    func();
                }
            }
        }

    }

}
}
