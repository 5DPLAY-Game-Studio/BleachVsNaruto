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

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.data.vos.BgmVO;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.kyo.utils.KyoUtils;

/**
 * 已注册的地图。
 *
 * <p>还没初始化时按 id 取值会抛错。地图曲的 id 固定写成 <code>map</code>，权重固定为 1。</p>
 *
 * @see MapVO
 */
public class MapModel {

    /** @private */
    private static var _i:MapModel;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 地图表。
     * @example
     * <listing version="3.0">
     * var map:MapVO = MapModel.I.getMap(id);
     * </listing>
     */
    public static function get I():MapModel {
        _i ||= new MapModel();
        return _i;
    }

    /** @private */
    private var _mapObj:Object;
    /** @private */
    [ArrayElementType('net.play5d.game.bvn.data.vos.MapVO')]
    private var _mapArray:Array;

    /**
     * 按 id 取地图。
     *
     * @param id 地图 id。
     * @return 地图。没有时为 <code>undefined</code>。表还没建时抛错。
     * @example
     * <listing version="3.0">
     * var map:MapVO = MapModel.I.getMap(id);
     * </listing>
     */
    public function getMap(id:String):MapVO {
        return _mapObj[id];
    }

    /**
     * 按地图 id 做一份背景音乐。
     *
     * <p>曲目 id 写成 <code>map</code>，不是地图 id。没有地图或没有地址时返回 <code>null</code>。</p>
     *
     * @param id 地图 id。
     * @return 曲目。
     * @example
     * <listing version="3.0">
     * var bgm:BgmVO = MapModel.I.getMapBGM(id);
     * </listing>
     */
    public function getMapBGM(id:String):BgmVO {
        var mv:MapVO = getMap(id);
        if (!mv || !mv.bgm) {
            return null;
        }

        var bv:BgmVO = new BgmVO();
        bv.id        = 'map';
        bv.url       = mv.bgm;
        bv.rate      = 1;
        return bv;
    }

    /**
     * 取全部地图。返回的是内部数组。
     *
     * @return 地图数组。还没初始化时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var maps:Array = MapModel.I.getAllMaps();
     * </listing>
     */
    public function getAllMaps():Array {
        return _mapArray;
    }

    /**
     * 用地图包对象重建表和数组。
     *
     * <p>缺少 <code>map</code> 或 <code>data</code> 时抛错。</p>
     *
     * @param obj 含 <code>map.path</code> 和 <code>map.data</code> 的对象。
     * @example
     * <listing version="3.0">
     * MapModel.I.initByObject(obj);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        _mapObj   = {};
        _mapArray = [];

        var mapObj:Object = obj['map'];
        for each(var i:Object in mapObj['data']) {
            var mapVOObj:Object = KyoUtils.cloneObject(i);
            mapVOObj['path']    = mapObj['path'];

            var mapVO:MapVO = new MapVO();
            mapVO.initByObject(mapVOObj);

            _mapObj[mapVO.id] = mapVO;
            _mapArray.push(mapVO);
        }
    }

    /**
     * 清空已注册地图。
     */
    public function clear():void {
        _mapObj   = {};
        _mapArray = [];
    }

    /**
     * 注册单个地图（同 id 覆盖）。
     *
     * @param mv 地图 VO。
     */
    public function register(mv:MapVO):void {
        if (!mv || !mv.id) {
            return;
        }
        _mapObj ||= {};
        _mapArray ||= [];

        if (_mapObj[mv.id]) {
            var idx:int = _mapArray.indexOf(_mapObj[mv.id]);
            if (idx >= 0) {
                _mapArray.splice(idx, 1);
            }
        }
        _mapObj[mv.id] = mv;
        _mapArray.push(mv);
    }

}
}
