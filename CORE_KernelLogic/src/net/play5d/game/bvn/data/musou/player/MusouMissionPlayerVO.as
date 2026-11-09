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

package net.play5d.game.bvn.data.musou.player {
import net.play5d.game.bvn.interfaces.ISaveData;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 玩家已通过的一关和星数。
 *
 * <p>读取时对象为空会抛错。没写星数时星数变成 0。</p>
 */
public class MusouMissionPlayerVO implements ISaveData, IInstanceVO {

    include '../../../../../../../../include/Clone.as';

    /**
     * 关卡 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 星数。
     *
     * @default 0
     */
    public var stars:int = 0;

    /**
     * 存 id 和星数。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = vo.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var o:Object = {};
        o.id         = id;
        o.stars      = stars;
        return o;
    }

    /**
     * 读 id 和星数。
     *
     * @param o 存档对象。为空时抛错。
     * @example
     * <listing version="3.0">
     * vo.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        id    = o.id;
        stars = o.stars;
    }
}
}
