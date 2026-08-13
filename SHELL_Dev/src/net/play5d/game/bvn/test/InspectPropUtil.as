/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.test {
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

/**
 * 属性检视共享工具：公开属性反射缓存、预览格式化与简单类型写回。
 *
 * @example
 * <listing version="3.0">
 * var props:Array = InspectPropUtil.getPublicProps(obj);
 * InspectPropUtil.applyValue(obj, 'x', 'Number', '10');
 * </listing>
 * @see #getPublicProps()
 * @see #formatPreview()
 * @see #applyValue()
 */
public class InspectPropUtil {
    /** @private 按类名缓存属性元数据 */
    private static var _propCache:Object = {};

    /**
     * 获取实例公开属性元数据（含继承），按类名缓存。
     * @param obj 目标实例。
     * @return 元数据数组 <code>{name, type, writable}</code>。
     * @example
     * <listing version="3.0">
     * var list:Array = InspectPropUtil.getPublicProps(sp);
     * </listing>
     */
    public static function getPublicProps(obj:Object):Array {
        if (!obj) {
            return [];
        }

        var qname:String = getQualifiedClassName(obj);
        var cached:Array = _propCache[qname] as Array;
        if (cached) {
            return cached;
        }

        var xml:XML     = describeType(obj);
        var list:Array  = [];
        var seen:Object = {};

        for each (var v:XML in xml.variable) {
            var vn:String = String(v.@name);
            if (seen[vn]) {
                continue;
            }
            seen[vn] = true;
            list[list.length] = {
                name    : vn,
                type    : String(v.@type),
                writable: true
            };
        }
        for each (var a:XML in xml.accessor) {
            var access:String = String(a.@access);
            if (access == 'writeonly') {
                continue;
            }
            var an:String = String(a.@name);
            if (seen[an]) {
                continue;
            }
            seen[an] = true;
            list[list.length] = {
                name    : an,
                type    : String(a.@type),
                writable: access == 'readwrite'
            };
        }
        list.sortOn('name');
        _propCache[qname] = list;

        return list;
    }

    /**
     * 是否为可编辑的简单类型。
     * @param typeName describeType 类型名。
     * @return 可编辑为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (InspectPropUtil.isEditableType('Number')) { }
     * </listing>
     */
    public static function isEditableType(typeName:String):Boolean {
        return typeName == 'Boolean'
                || typeName == 'Number'
                || typeName == 'int'
                || typeName == 'uint'
                || typeName == 'String';
    }

    /**
     * 可编辑值转为输入框文本。
     * @param value 属性值。
     * @return 文本。
     * @example
     * <listing version="3.0">
     * var t:String = InspectPropUtil.editableToString(1.5);
     * </listing>
     */
    public static function editableToString(value:*):String {
        if (value == null) {
            return '';
        }

        return String(value);
    }

    /**
     * 将编辑文本写回目标属性。
     * @param target 目标对象。
     * @param propName 属性名。
     * @param typeName 类型名。
     * @param text 输入文本。
     * @return 写回成功为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * InspectPropUtil.applyValue(sp, 'x', 'Number', '100');
     * </listing>
     */
    public static function applyValue(target:Object, propName:String, typeName:String, text:String):Boolean {
        if (!target) {
            return false;
        }

        try {
            if (typeName == 'String') {
                target[propName] = text;

                return true;
            }
            if (typeName == 'Boolean') {
                target[propName] = text == 'true' || text == '1';

                return true;
            }
            if (typeName == 'int' || typeName == 'uint' || typeName == 'Number') {
                if (text == '' || text == '-' || text == '.' || text == '-.') {
                    return false;
                }
                var n:Number = Number(text);
                if (isNaN(n)) {
                    return false;
                }
                if (typeName == 'int') {
                    target[propName] = int(n);
                }
                else if (typeName == 'uint') {
                    target[propName] = uint(n);
                }
                else {
                    target[propName] = n;
                }

                return true;
            }
        }
        catch (e:Error) {
            return false;
        }

        return false;
    }

    /**
     * 判断是否存在有意义的 <code>toString()</code>（非默认 <code>[object Xxx]</code>）。
     * @param value 任意值。
     * @return 有意义时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (InspectPropUtil.hasUsefulToString(v)) { }
     * </listing>
     */
    public static function hasUsefulToString(value:*):Boolean {
        if (value == null) {
            return false;
        }
        if (value is String || value is Boolean || value is Number || value is int || value is uint) {
            return true;
        }
        if (value is XML || value is XMLList || value is Array) {
            return true;
        }

        var s:String;
        try {
            s = value.toString();
        }
        catch (e:Error) {
            return false;
        }
        if (!s) {
            return false;
        }

        var shortName:String = shortClassName(value);
        if (s == '[object ' + shortName + ']' || s == '[object Object]') {
            return false;
        }
        if (s == shortName || s == getQualifiedClassName(value)) {
            return false;
        }

        return true;
    }

    /**
     * 将属性值格式化为只读展示文本。
     * @param value 属性值。
     * @return 展示文本。
     * @example
     * <listing version="3.0">
     * var t:String = InspectPropUtil.formatPreview(rect);
     * </listing>
     */
    public static function formatPreview(value:*):String {
        if (value == null) {
            return 'null';
        }
        if (value is String) {
            var s:String = value as String;
            if (s.length > 40) {
                return '\'' + s.substr(0, 37) + '...\'';
            }

            return '\'' + s + '\'';
        }
        if (value is Boolean || value is Number || value is int || value is uint) {
            return String(value);
        }
        if (value is Array) {
            return 'Array(' + (value as Array).length + ')';
        }
        if (value is Rectangle) {
            var r:Rectangle = value as Rectangle;

            return 'Rectangle(' + r.x + ', ' + r.y + ', ' + r.width + ', ' + r.height + ')';
        }
        if (value is DisplayObject) {
            var d:DisplayObject = value as DisplayObject;

            return shortClassName(d) + ' @(' + d.x + ', ' + d.y + ')';
        }
        if (hasUsefulToString(value)) {
            try {
                var t:String = value.toString();
                if (t.length > 40) {
                    return t.substr(0, 37) + '...';
                }

                return t;
            }
            catch (e:Error) {
            }
        }

        return shortClassName(value);
    }

    /**
     * 取限定名末段。
     * @param value 任意对象。
     * @return 短类名。
     * @example
     * <listing version="3.0">
     * var n:String = InspectPropUtil.shortClassName(sp);
     * </listing>
     */
    public static function shortClassName(value:*):String {
        var qname:String = getQualifiedClassName(value);
        var slash:int    = qname.lastIndexOf('::');
        if (slash >= 0) {
            return qname.substr(slash + 2);
        }

        return qname;
    }
}
}
