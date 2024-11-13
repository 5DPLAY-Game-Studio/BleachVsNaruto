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

package {

/**
 *
 * @param instance 实例
 * @param elementName 元素名，可以为 "prop" 或 "method()"
 * @return
 */
public function GetElement(instance:*, elementName:String):* {
    if (!instance) {
        return null;
    }

    /**
     * 获取属性
     *
     * @param propName 属性名
     * @return 属性值
     */
    var getProperties:Function = null;
    try {
        getProperties = instance['getProperties'] as Function;
    }
    catch (e:Error) {
        return null;
    }

    if (getProperties == null) {
        return null;
    }

    var result:* = null;

    try {
        const BRACKET:String = '()';

        if (elementName.indexOf(BRACKET) != -1) {
            // 是方法则消除括号
            elementName = elementName.substr(0, elementName.length - BRACKET.length);
        }

        result = getProperties(elementName);
    }
    catch (e:Error) {
        ThrowError(e, 'Error executing the specified method!');
    }

    return result;
}
}
