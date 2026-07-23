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

package net.play5d.game.bvn.utils {
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.alice.utils.ClassUtils;

/**
 * <code>IInstanceVO</code> 浅克隆工具。
 *
 * <p>按 <code>Class</code> 缓存可拷贝属性名，供 <code>include/Clone.as</code> 委托调用。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IInstanceVO
 */
public class InstanceVOClone {

    /** @private 按 Class 缓存的属性名列表 */
    private static var _propCache:Dictionary = new Dictionary(true);

    /**
     * 浅克隆源对象为同类型 <code>IInstanceVO</code>。
     *
     * @param source 源实例。
     * @param args 构造参数；仅支持长度 0–2。
     * @return 克隆实例。
     * @throws ArgumentError 构造参数个数超出支持范围。
     * @example
     * <listing version="3.0">
     * var copy:IInstanceVO = InstanceVOClone.clone(vo, [vo.id]);
     * </listing>
     * @see net.play5d.game.bvn.interfaces.IInstanceVO#clone()
     */
    public static function clone(source:Object, args:Array = null):IInstanceVO {
        var cls:Class      = getDefinitionByName(getQualifiedClassName(source)) as Class;
        var vo:IInstanceVO = createInstance(cls, args);
        var keys:Array     = getPropertyKeys(cls);

        for each (var prop:String in keys) {
            vo[prop] = source[prop];
        }

        return vo;
    }

    /** @private 按参数个数构造实例（0–2） */
    private static function createInstance(cls:Class, args:Array):IInstanceVO {
        var len:int = args ? args.length : 0;
        if (len == 0) {
            return new cls() as IInstanceVO;
        }
        if (len == 1) {
            return new cls(args[0]) as IInstanceVO;
        }
        if (len == 2) {
            return new cls(args[0], args[1]) as IInstanceVO;
        }
        throw new ArgumentError('InstanceVOClone: unsupported ctor arity ' + len);
    }

    /** @private 获取并缓存类的可拷贝属性名 */
    private static function getPropertyKeys(cls:Class):Array {
        var keys:Array = _propCache[cls] as Array;
        if (!keys) {
            keys            = ClassUtils.getClassProperty(cls);
            _propCache[cls] = keys;
        }
        return keys;
    }

}
}
