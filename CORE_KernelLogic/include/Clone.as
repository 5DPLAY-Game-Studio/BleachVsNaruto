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

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import net.play5d.game.bvn.interfaces.IInstanceVO;

import net.play5d.pcl.utils.ClassUtils;

/**
 * 克隆自身
 * @return 返回自身实例的克隆对象
 */
public function clone():IInstanceVO {
    var clsName:String = getQualifiedClassName(this);
    var cls:Class      = getDefinitionByName(clsName) as Class;
    var vo:IInstanceVO = new cls();
    var keys:Array     = ClassUtils.getClassProperty(cls);

    for each (var prop:String in keys) {
        vo[prop] = this[prop];
    }

    return vo;
}