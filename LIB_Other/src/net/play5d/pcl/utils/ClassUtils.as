/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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
import flash.utils.Dictionary;
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

    ////////////////////////////////////////////////////////////////////////////////

    /**
     * 路径访问器缓存
     * key: 路径数组的字符串表示
     * value: 预编译的访问函数
     */
    private static var _pathCache:Dictionary = new Dictionary(true);
    
    /**
     * 连续访问对象的嵌套属性或方法（优化版）
     * @param begin 起始对象
     * @param list 属性/方法路径数组，方法以 "()" 结尾
     * @return 访问路径末端的对象，访问失败返回 null
     */
    public static function continuousAccess(begin:*, list:Array = null):* {
        if (begin == null) {
            return null;
        }
        if (list == null || list.length == 0) {
            return begin;
        }

        // 尝试从缓存获取预编译的访问器
        var cacheKey:String = list.join(',');
        var accessor:Function = _pathCache[cacheKey];
        
        // 缓存中存在，直接返回结果
        if (accessor != null) {
            return accessor(begin);
        }

        // 缓存中不存在，编译访问器函数并缓存
        accessor = _compileAccessor(list);
        _pathCache[cacheKey] = accessor;
        
        return accessor(begin);
    }

    /**
     * 编译路径数组为高效的访问器函数
     * @param list 属性/方法路径数组
     * @return 编译后的访问函数
     */
    private static function _compileAccessor(list:Array):Function {
        var len:int = list.length;
        var accessors:Array = [];
        
        for (var i:int = 0; i < len; i++) {
            var node:String = list[i];
            var isMethod:Boolean = node.length > 2 && 
                                   node.charCodeAt(node.length - 2) == 40 &&  // '('
                                   node.charCodeAt(node.length - 1) == 41;    // ')'
            
            if (isMethod) {
                var methodName:String = node.substring(0, node.length - 2);
                // 使用闭包捕获方法名
                accessors.push(_createMethodAccessor(methodName));
            } else {
                // 使用闭包捕获属性名
                accessors.push(_createPropertyAccessor(node));
            }
        }
        
        // 返回组合后的访问函数
        return function(root:*):* {
            var current:* = root;
            for each (var func:Function in accessors) {
                if (current == null) {
                    return null;
                }

                current = func(current);
                
                if (current == null) {
                    return null;
                }
            }
            return current;
        };
    }

    /**
     * 创建属性访问器
     */
    private static function _createPropertyAccessor(name:String):Function {
        return function(obj:*):* {
            return obj[name];
        };
    }

    /**
     * 创建方法访问器
     */
    private static function _createMethodAccessor(name:String):Function {
        return function(obj:*):* {
            return obj[name] ? obj[name]() : null;
        };
    }
}
}
