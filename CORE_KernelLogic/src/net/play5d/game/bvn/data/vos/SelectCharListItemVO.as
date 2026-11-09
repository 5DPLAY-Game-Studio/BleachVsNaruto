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

package net.play5d.game.bvn.data.vos {
import flash.geom.Point;

import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 选人列表里的一格。
 *
 * <p><code>getAllFighterIDs</code> 在主 id 为空时不放入。额外 id 会原样接上，里面的空值也留着。</p>
 */
public class SelectCharListItemVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 记下格子坐标、主角色和偏移。
     *
     * @param x 列。
     * @param y 行。
     * @param fighterID 主角色 id。可以为 <code>null</code>。
     * @param offset 偏移。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var item:SelectCharListItemVO = new SelectCharListItemVO(0, 0, id);
     * </listing>
     */
    public function SelectCharListItemVO(x:int, y:int, fighterID:String, offset:Point = null) {
        this.x         = x;
        this.y         = y;
        this.fighterID = fighterID;
        this.offset    = offset;
    }

    /**
     * 列。
     *
     * @default 0
     */
    public var x:int;
    /**
     * 行。
     *
     * @default 0
     */
    public var y:int;
    /**
     * 主角色 id。
     *
     * @default null
     */
    public var fighterID:String;
    /**
     * 相对本行的偏移。
     *
     * @default null
     */
    public var offset:Point;
    /**
     * 同一格的其它角色 id。
     *
     * @default null
     */
    public var moreFighterIDs:Array;

    /**
     * 主 id 加上额外 id。
     *
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var ids:Array = item.getAllFighterIDs();
     * </listing>
     */
    public function getAllFighterIDs():Array {
        var a:Array = [];
        if (fighterID) {
            a.push(fighterID);
        }
        if (moreFighterIDs && moreFighterIDs.length > 0) {
            a = a.concat(moreFighterIDs);
        }
        return a;
    }
}
}
