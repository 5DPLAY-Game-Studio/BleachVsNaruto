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

package net.play5d.pcl.utils {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

public class ClassUtils {

    /**
     * 获得某个类的所有公开属性
     * @param cls 类
     * @return
     */
    public static function getClassProperty(cls:Class):Array {
        if (!cls) {
            return null;
        }

        var publicKey:Array = [];

        var clsXml:XML;
        var variables:XMLList;
        try {
            clsXml    = describeType(cls);
            variables = clsXml.factory.variable;
        }
        catch (e:Error) {
            trace('转换失败！');
        }

        if (variables == null) {
            return null;
        }

        for each(var varXml:XML in variables) {
            var name:String = varXml.@name;
            publicKey.push(name);
        }

        //trace(publicKey);
        return publicKey;
    }

    /**
     * 获得某个值对象的类名
     * @param value 值对象
     * @return
     */
    public static function getClassName(value:*):String {
        if (value == null) {
            return null;
        }

        return getQualifiedClassName(value);
    }

    /**
     * 获得某个值对象的所有定义的 Event 事件
     * @param value 值对象
     * @return event 事件组
     */
    public static function getClassEventMethod(value:*):Array {
        if (value == null) {
            return null;
        }

        // 事件函数
        var eventFuncs:Array = [];

        var clsXml:XML;
        var methods:XMLList;
        try {
            clsXml  = describeType(value);
            methods = clsXml.method;
        }
        catch (e:Error) {
            trace('转换失败！');
        }

        if (methods == null) {
            return null;
        }

        var className:String = getClassName(value);
        var eventName:String = getClassName(Event);

        for each (var methodXml:XML in methods) {
            var declaredBy:String = methodXml.@declaredBy;
            if (declaredBy != className) {
                continue;
            }

            var parameters:XMLList = methodXml.parameter;
            if (parameters.length() != 1) {
                continue;
            }

            var parameter:XML        = parameters[0];
            var parameterType:String = parameter.@type;

            if (parameterType == eventName) {
                var name:String = methodXml.@name;
                eventFuncs.push(name);
            }
        }

        return eventFuncs;
    }

    /**
     * 移除显示对象的所有 EnterFrame 事件
     * @param d 显示对象
     * @param back 回调函数，需要一个参数 eventName:String
     */
    public static function removeAllEventListener(d:DisplayObject, back:Function = null):void {
        if (d == null || !d.hasEventListener(Event.ENTER_FRAME)) {
            return;
        }

        var eventMethods:Array = getClassEventMethod(d);
        if (eventMethods == null) {
            return;
        }

        for each (var eventName:String in eventMethods) {
            var eventFunc:Function = d[eventName] as Function;
            if (eventFunc == null || !d.hasEventListener(Event.ENTER_FRAME)) {
                continue;
            }

            d.removeEventListener(Event.ENTER_FRAME, eventFunc);
            if (back != null) {
                back(eventName);
            }
        }
    }

    /**
     * 连续访问
     * @param begin 起始节点
     * @param list 依次访问的属性/方法（方法要加"()"）
     * @return 最终结果
     */
    public static function continuousAccess(begin:*, list:Array = null):* {
        if (begin == null) {
            return null;
        }
        if (list == null || list.length == 0) {
            return begin;
        }

        /**
         * 检查是否具有指定属性
         * @param name 属性名
         * @return 是否具有指定属性
         */
        function check(name:String):Boolean {
            return begin.hasOwnProperty(name);
        }

        var len:int = list.length;
        for (var i:int = 0; i < len; ++i) {
            var nextNode:String = list[i] as String;
            if (nextNode == null) {
                return null;
            }

            try {
                const BRACKET:String = '()';

                if (nextNode.indexOf(BRACKET) == -1) {
                    if (!check(nextNode)) {
                        return null;
                    }

                    // 非函数式访问
                    if (begin[nextNode] != null) {
                        begin = begin[nextNode];
                    }
                }
                else {
                    // 函数式访问
                    var nodeNameLen:int = nextNode.length - BRACKET.length;
                    nextNode            = nextNode.substr(0, nodeNameLen);

                    if (!check(nextNode)) {
                        return null;
                    }

                    if (begin[nextNode]() != null) {
                        begin = begin[nextNode]();
                    }
                }
            }
            catch (e:Error) {
                trace('ClassUtil.continuousAccess::' + e);
                return null;
            }
        }

        return begin;
    }
}
}
