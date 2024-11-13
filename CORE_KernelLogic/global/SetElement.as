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
 * @param value 值
 */
public function SetElement(instance:*, elementName:String, value:*):void {
    if (!instance) {
        return;
    }

    /**
     * 设置属性
     *
     * @param propName 属性名
     * @param value 属性值
     */
    var setProperties:Function = null;
    try {
        setProperties = instance['setProperties'] as Function;
    }
    catch (e:Error) {
        return;
    }

    if (setProperties == null) {
        return;
    }

    try {
        setProperties(elementName, value);
    }
    catch (e:Error) {
        ThrowError(e, 'Error executing the specified method!');
    }
}
}
