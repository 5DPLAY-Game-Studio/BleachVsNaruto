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
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/**
 * Object 工具类，用于深复制目标对象 <br/>
 * 仅能复制目标对象的 <b>public</b> 属性，且构造函数<b>不可有参数</b> <br/>
 * <br/>
 * 摘自 https://www.cnblogs.com/skybdemq/p/3143601.html
 */
public class ObjectUtils {

    /**
     * <b>深复制</b> 目标对象
     * @param $object 目标对象
     * @return 目标对象的 <b>深复制</b> 副本
     */
    public static function cloneObject($object:*):* {
        if (!$object) {
//            throw new ArgumentError('Parameter $object can not be null.');
            return null;
        }

        // 为了深度复制一个对象, 需要注册该对象用到的所有类
        var allClassName:Array = getAllQualifiedClassName($object);
        for each(var aliasName:String in allClassName) {
            var classObject:Class = Class(getDefinitionByName(aliasName));
            registerClassAlias(aliasName, classObject);
        }

        // 使用 byteArray 对象进行深度复制即可
        var bytes:ByteArray = new ByteArray();
        bytes.writeObject($object);
        bytes.position = 0;

        // 取出复制出的新对象，如果有带参数的构造函数而导致复制失败的就返回 null
        var className:String  = getQualifiedClassName($object);
        var ObjectClass:Class = Class(getDefinitionByName(className));
        try {
            return bytes.readObject() as ObjectClass;
        }
        catch ($error:ArgumentError) {
//            trace($error.message);
        }

        return null;
    }

    /**
     * 获取目标对象的全部 <b>全限定类名称</b>
     * @param $object 目标对象
     * @return 目标对象的全部全限定类名称
     */
    public static function getAllQualifiedClassName($object:*):Array {
        if (!$object) {
//            throw new ArgumentError('Parameter $object can not be null.');
            return null;
        }

        var result:Array          = [];
        var xml:XML               = describeType($object);
        var dictionary:Dictionary = new Dictionary();
        dictionary[xml.@name]     = true;

        var i:int, j:int;
        var key:String, key2:String;
        for (i = 0; i < xml.extendsClass.length(); i++) {
            key             = String(xml.extendsClass[i].@type);
            dictionary[key] = true;
        }
        for (i = 0; i < xml.implementsInterface.length(); i++) {
            key             = String(xml.implementsInterface[i].@type);
            dictionary[key] = true;
        }
        for (i = 0; i < xml.accessor.length(); i++) {
            key             = String(xml.accessor[i].@type);
            dictionary[key] = true;
        }
        for (i = 0; i < xml.method.length(); i++) {
            key             = String(xml.method[i].@returnType);
            dictionary[key] = true;
            for (j = 0; j < xml.method[i].parameter.length(); j++) {
                key2             = String(xml.method[i].parameter[j].@type);
                dictionary[key2] = true;
            }
        }

        for (var obj:* in dictionary) {
            var toString:String = obj.toString();
            if (toString != 'void' && toString != '*') {
                result.push(toString);
            }
        }
        return result;
    }
}
}
