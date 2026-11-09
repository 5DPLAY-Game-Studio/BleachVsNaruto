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
import net.play5d.game.bvn.ctrler.AssetManager;

/**
 * 已加载的无双地图和当前关卡。
 *
 * <p>加载固定读 <code>config/musou/map1/map1.json</code>，再按 <code>parts</code> 逐个读区域。
 * 区域文件失败时调用 <code>fail</code> 并停掉后面的区域。区域 JSON 没有 <code>id</code> 时跳过这一份，继续下一份。
 * <code>parts</code> 为空时不读区域，直接调用 <code>back</code>。地图还没加载时，<code>getMap</code> 得到 <code>undefined</code>。</p>
 *
 * @see MusouWorldMapVO
 * @author K
 */
public class MusouModel {

    /** @private */
    private static var _i:MusouModel;

    /**
     * 单例。第一次访问时创建。
     *
     * @return 地图数据。
     * @example
     * <listing version="3.0">
     * var model:MusouModel = MusouModel.I;
     * </listing>
     */
    public static function get I():MusouModel {
        _i ||= new MusouModel();
        return _i;
    }

    /**
     * 当前区域配置。
     *
     * @default null
     */
    public var currentArea:MusouWorldMapAreaVO;
    /**
     * 当前关卡配置。
     *
     * @default null
     */
    public var currentMission:MusouMissionVO;
    /** @private */
    private var _mapObj:Object = {};

    /**
     * 已加载的地图表。键是地图 id。
     *
     * @return 地图表本身。
     * @example
     * <listing version="3.0">
     * var maps:Object = MusouModel.I.getAllMap();
     * </listing>
     */
    public function getAllMap():Object {
        return _mapObj;
    }

    /**
     * 按 id 取地图。
     *
     * @param id 地图 id。
     * @return 地图。没有时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var map:MusouWorldMapVO = MusouModel.I.getMap('map1');
     * </listing>
     */
    public function getMap(id:String):MusouWorldMapVO {
        return _mapObj[id];
    }

    /**
     * 按地图和区域 id 取区域。
     *
     * @param mapId 地图 id。
     * @param areaId 区域 id。
     * @return 区域。地图不存在时为 <code>null</code>。区域不存在时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var area:MusouWorldMapAreaVO = MusouModel.I.getMapArea('map1', 'p1');
     * </listing>
     */
    public function getMapArea(mapId:String, areaId:String):MusouWorldMapAreaVO {
        var map:MusouWorldMapVO = _mapObj[mapId];
        if (!map) {
            return null;
        }
        return map.getArea(areaId);
    }

    /**
     * 加载 <code>map1</code> 和它的区域文件。
     *
     * @param back 全部读完后调用。
     * @param fail 地图或某个区域失败时调用。
     * @example
     * <listing version="3.0">
     * MusouModel.I.loadMapData(onOk, onFail);
     * </listing>
     */
    public function loadMapData(back:Function, fail:Function):void {
        var mapId:String = 'map1';
        var url:String   = 'config/musou/' + mapId + '/' + mapId + '.json';
        AssetManager.I.loadJSON(url, function (o:Object):void {
            var map:MusouWorldMapVO = new MusouWorldMapVO();
            map.id                  = o.id;
            map.name                = o.name;
            map.initWay(o.way);
            _mapObj[map.id] = map;
            loadAreas(map, o.parts, back, fail);

        }, fail);
    }

    /** @private */
    private function loadAreas(map:MusouWorldMapVO, parts:Array, back:Function, fail:Function):void {
        var mapIds:Array = parts.concat();

        function loadNext(o:Object = null):void {
            if (!o) {
                (
                        fail != null
                ) && fail();
                return;
            }

            if (o && o.id) {
                var mv:MusouWorldMapAreaVO = map.getArea(o.id);
                if (mv) {
                    initMapArea(mv, o);
                }
            }

            if (mapIds.length < 1) {
                (
                        back != null
                ) && back();
                return;
            }

            var id:String = mapIds.shift();

            var partUrl:String = 'config/musou/' + map.id + '/' + id + '.json';
            TraceLang('musou_model.load_area', {areaUrl: partUrl});
            AssetManager.I.loadJSON(partUrl, loadNext, fail);
        }

        loadNext({remark: 'first time!'});
    }

    /** @private */
    private function initMapArea(area:MusouWorldMapAreaVO, d:Object):void {
        TraceLang('musou_model.init_map_area', {areaId: d.id});

        area.id   = d.id;
        area.name = d.name;

        area.missions = new Vector.<MusouMissionVO>();

        var miss:Array = d.missions;
        for (var j:int = 0; j < miss.length; j++) {
            var mv:MusouMissionVO = new MusouMissionVO();
            mv.initByJsonObject(miss[j]);
            area.missions.push(mv);
        }

    }

}
}
