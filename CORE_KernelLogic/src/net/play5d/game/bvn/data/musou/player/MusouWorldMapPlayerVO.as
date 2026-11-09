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
 * 玩家已开放的一张地图。
 *
 * <p>重复开放同一个区域不会再建一份。读取时没有 <code>id</code> 会留着原来的 id。没有 <code>areas</code> 时不清已开放的区域。</p>
 *
 * @see MusouWorldMapAreaPlayerVO
 */
public class MusouWorldMapPlayerVO implements ISaveData, IInstanceVO {

    include '../../../../../../../../include/Clone.as';

    /**
     * 地图 id。
     *
     * @default null
     */
    public var id:String;
    /** @private */
    private var _openAreas:Vector.<MusouWorldMapAreaPlayerVO> = new Vector.<MusouWorldMapAreaPlayerVO>();

    /**
     * 按 id 取已开放区域。
     *
     * @param id 区域 id。
     * @return 区域进度。没开放时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var area:MusouWorldMapAreaPlayerVO = map.getOpenArea(id);
     * </listing>
     */
    public function getOpenArea(id:String):MusouWorldMapAreaPlayerVO {
        for (var i:int; i < _openAreas.length; i++) {
            if (_openAreas[i].id == id) {
                return _openAreas[i];
            }
        }
        return null;
    }

    /**
     * 开放一个区域。已经开放时什么都不做。
     *
     * @param id 区域 id。
     * @example
     * <listing version="3.0">
     * map.openArea(id);
     * </listing>
     */
    public function openArea(id:String):void {
        if (!getOpenArea(id)) {
            var musouWorldMapAreaPlayerVO:MusouWorldMapAreaPlayerVO = new MusouWorldMapAreaPlayerVO();
            musouWorldMapAreaPlayerVO.id                            = id;
            _openAreas.push(musouWorldMapAreaPlayerVO);
        }
    }

    /**
     * 存地图 id 和已开放区域。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = map.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var o:Object = {};
        o.id         = id;

        o.areas = [];
        for (var i:int; i < _openAreas.length; i++) {
            var ad:Object = _openAreas[i].toSaveObj();
            o.areas.push(ad);
        }

        return o;
    }

    /**
     * 读地图 id 和区域。
     *
     * <p>对象为空时抛错。id 为空时不改原来的 id。没有 <code>areas</code> 时保留已有区域。</p>
     *
     * @param o 存档对象。
     * @example
     * <listing version="3.0">
     * map.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        if (o.id) {
            id = o.id;
        }

        if (o.areas) {
            _openAreas = new Vector.<MusouWorldMapAreaPlayerVO>();
            for (var i:int; i < o.areas.length; i++) {
                var ad:Object                                           = o.areas[i];
                var musouWorldMapAreaPlayerVO:MusouWorldMapAreaPlayerVO = new MusouWorldMapAreaPlayerVO();
                musouWorldMapAreaPlayerVO.readSaveObj(ad);
                _openAreas.push(musouWorldMapAreaPlayerVO);
            }
        }
    }

}
}
