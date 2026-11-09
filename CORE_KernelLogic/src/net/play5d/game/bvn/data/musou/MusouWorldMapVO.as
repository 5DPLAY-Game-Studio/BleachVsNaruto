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
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一张无双世界地图和区域开放关系。
 *
 * <p><code>initWay</code> 用 <code>P</code> 当区域 id，用 <code>N</code> 当前置。
 * <code>N</code> 可以是一个 id，也可以是 id 数组。对不上的 id 会丢掉。没有 <code>N</code> 时前置保持 <code>null</code>。
 * 同一个 <code>P</code> 出现两次时，表里只留后一个，数组里两个都在。</p>
 *
 * @see MusouWorldMapAreaVO
 */
public class MusouWorldMapVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 地图 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 名字。
     *
     * @default null
     */
    public var name:String;
    /**
     * 区域。初始化前为 <code>null</code>。
     *
     * @default null
     */
    public var areas:Vector.<MusouWorldMapAreaVO>;
    /** @private */
    private var _areaMap:Object;

    /**
     * 按路线建区域和前置。
     *
     * @param way 路线。每一项有 <code>P</code>，可选 <code>N</code>。为空时抛错。
     * @example
     * <listing version="3.0">
     * map.initWay(json.way);
     * </listing>
     */
    public function initWay(way:Array):void {
        areas    = new Vector.<MusouWorldMapAreaVO>();
        _areaMap = {};

        var i:int, w:Object, mv:MusouWorldMapAreaVO;

        for (i = 0; i < way.length; i++) {
            w     = way[i];
            mv    = new MusouWorldMapAreaVO();
            mv.id = w.P;

            areas.push(mv);
            _areaMap[mv.id] = mv;
        }

        for (i = 0; i < way.length; i++) {
            w  = way[i];
            mv = _areaMap[w.P];

            if (!mv || !w.N) {
                continue;
            }

            mv.preOpens = new Vector.<MusouWorldMapAreaVO>();

            if (w.N is Array) {
                for each(var id:String in w.N) {
                    if (_areaMap[id]) {
                        mv.preOpens.push(_areaMap[id]);
                    }
                }
            }
            else {
                if (_areaMap[w.N]) {
                    mv.preOpens.push(_areaMap[w.N]);
                }
            }

        }
    }

    /**
     * 按 id 取区域。
     *
     * <p>还没 <code>initWay</code> 时抛错。没有这个 id 时为 <code>undefined</code>。</p>
     *
     * @param aid 区域 id。
     * @return 区域。
     * @example
     * <listing version="3.0">
     * var area:MusouWorldMapAreaVO = map.getArea(id);
     * </listing>
     */
    public function getArea(aid:String):MusouWorldMapAreaVO {
        return _areaMap[aid];
    }

}
}
