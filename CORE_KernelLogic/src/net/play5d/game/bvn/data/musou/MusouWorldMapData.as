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

package net.play5d.game.bvn.data.musou {
import net.play5d.game.bvn.interfaces.ISaveData;

/**
 * 世界地图存档占位。
 *
 * <p>保存一直返回 <code>null</code>。读取什么都不做。</p>
 */
public class MusouWorldMapData implements ISaveData {

    /** @private */
    private var _mapAreaList:Vector.<MusouWorldMapAreaVO>;

    /**
     * 保存。当前固定返回 <code>null</code>。
     *
     * @return <code>null</code>。
     * @example
     * <listing version="3.0">
     * var o:Object = data.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        return null;
    }

    /**
     * 读取。当前不写任何字段。
     *
     * @param o 存档对象。可以是 <code>null</code>。
     * @example
     * <listing version="3.0">
     * data.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
    }

    /** @private */
    private function initMapAreas():void {
    }
}
}
