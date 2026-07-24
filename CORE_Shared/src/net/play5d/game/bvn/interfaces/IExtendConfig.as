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

package net.play5d.game.bvn.interfaces {

/**
 * 扩展配置接口。
 *
 * <p>将扩展配置序列化到存档对象，或从存档对象还原。</p>
 *
 * @see ISaveData
 */
public interface IExtendConfig {

    /**
     * 保存到存档数据对象。
     *
     * @return 存档数据对象。
     */
    function toSaveObj():Object;

    /**
     * 从存档数据对象读取。
     *
     * @param obj 存档数据对象。
     */
    function readSaveObj(obj:Object):void;
}
}
