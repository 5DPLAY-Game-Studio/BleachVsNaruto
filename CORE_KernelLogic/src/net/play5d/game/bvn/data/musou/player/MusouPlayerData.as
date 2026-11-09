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
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.MusouWorldMapAreaVO;
import net.play5d.game.bvn.data.musou.MusouWorldMapVO;
import net.play5d.game.bvn.data.musou.utils.MusouFighterFactory;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.kyo.utils.WrapInteger;

/**
 * 无双玩家的钱、角色、队伍和地图进度。
 *
 * <p><code>init</code> 把钱设成 3000，再追加一护、鸣人和小樱，队伍是这三人的另一份列表。地图还没加载时会在开放区域处抛错。再调一次会再追加一份角色和地图。
 * 队长换到 1 号位时，原队长到 2 号、原 2 号到 1 号。换到 2 号位时，原队长到 1 号、原 1 号到 2 号。人不在队伍里，或已经是队长，则直接返回。
 * 队伍不足 3 人时写到后面的格子会抛错。下标大于 2 时不换位，但仍派队伍更新。
 * 加钱可以减成负数。花钱最低到 0。队长拿双倍经验。
 * 读档时钱、登录时间、地图 id、区域 id 为 0 或空会跳过。队伍里找不到的角色 id 会被丢掉。登录时间用 <code>int</code> 截断。</p>
 *
 * @see MusouFighterVO
 */
public class MusouPlayerData implements ISaveData {

    /**
     * 用户 id。
     *
     * @default null
     */
    public var userId:String;
    /**
     * 用户名。
     *
     * @default null
     */
    public var userName:String;
    /** @private */
    private var _money:WrapInteger                      = new WrapInteger(0);
    /** @private */
    private var _mapData:Vector.<MusouWorldMapPlayerVO> = new Vector.<MusouWorldMapPlayerVO>();
    /** @private */
    private var _fighterData:Vector.<MusouFighterVO>    = new Vector.<MusouFighterVO>();
    /** @private */
    private var _fighterTeam:Vector.<MusouFighterVO>    = new Vector.<MusouFighterVO>();
    /** @private */
    private var _lastLogin:WrapInteger                  = new WrapInteger(0);
    /** @private */
    private var _currentMapId:String                    = 'map1';
    /** @private */
    private var _currentAreaId:String                   = 'p1';

    /**
     * 准备新档：钱 3000，三个初始角色，并开放没有前置的区域。
     *
     * @example
     * <listing version="3.0">
     * data.init();
     * </listing>
     */
    public function init():void {
        initMap();

        _money.setValue(3000);

        _fighterData.push(MusouFighterFactory.create('ichigo'));
        _fighterData.push(MusouFighterFactory.create('naruto'));
        _fighterData.push(MusouFighterFactory.create('sakura'));

        _fighterTeam = _fighterData.concat();
    }

    /**
     * 拥有的角色。返回的是内部列表。
     *
     * @return 角色列表。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;MusouFighterVO&gt; = data.getFighterData();
     * </listing>
     */
    public function getFighterData():Vector.<MusouFighterVO> {
        return _fighterData;
    }

    /**
     * 加入角色。已经有这个 id 时返回原来那份。
     *
     * @param id 角色 id。
     * @return 已有的或新建的角色。
     * @example
     * <listing version="3.0">
     * var vo:MusouFighterVO = data.addFighter(id);
     * </listing>
     */
    public function addFighter(id:String):MusouFighterVO {
        var fv:MusouFighterVO = getFighterDataById(id);

        if (fv) {
            return fv;
        }

        fv = MusouFighterFactory.create(id);
        _fighterData.push(fv);

        return fv;
    }

    /**
     * 出战队伍。下标 0 是队长。返回的是内部列表。
     *
     * @return 队伍。
     * @example
     * <listing version="3.0">
     * var team:Vector.&lt;MusouFighterVO&gt; = data.getFighterTeam();
     * </listing>
     */
    public function getFighterTeam():Vector.<MusouFighterVO> {
        return _fighterTeam;
    }

    /**
     * 出战角色 id。
     *
     * @return id 列表。
     * @example
     * <listing version="3.0">
     * var ids:Array = data.getFighterTeamIds();
     * </listing>
     */
    public function getFighterTeamIds():Array {
        var ids:Array = [];
        for (var i:int; i < _fighterTeam.length; i++) {
            ids.push(_fighterTeam[i].id);
        }
        return ids;
    }

    /**
     * 把已拥有的角色放到队伍的这个位置。
     *
     * <p>还没拥有这个 id 时直接返回。下标超出队伍长度时抛错。</p>
     *
     * @param index 队伍下标。
     * @param id 角色 id。
     * @example
     * <listing version="3.0">
     * data.setFighterTeam(1, id);
     * </listing>
     */
    public function setFighterTeam(index:int, id:String):void {
        var mv:MusouFighterVO = getFighterDataById(id);
        if (!mv) {
            return;
        }
        _fighterTeam[index] = mv;

        GameEvent.dispatchEvent(GameEvent.MUSOU_FIGHTER_UPDATE);
    }

    /**
     * 把这个角色换成队长。
     *
     * @param v 队伍里的角色。不在队伍里，或已经是队长时直接返回。
     * @example
     * <listing version="3.0">
     * data.setLeader(vo);
     * </listing>
     */
    public function setLeader(v:MusouFighterVO):void {
        var index:int = _fighterTeam.indexOf(v);
        if (index == -1) {
            return;
        }
        if (index == 0) {
            return;
        }

        var tmp:Vector.<MusouFighterVO> = _fighterTeam.concat();

        switch (index) {
        case 1:
            _fighterTeam[2] = tmp[0];
            _fighterTeam[1] = tmp[2];
            _fighterTeam[0] = tmp[1];
            break;
        case 2:
            _fighterTeam[2] = tmp[1];
            _fighterTeam[1] = tmp[0];
            _fighterTeam[0] = tmp[2];
            break;
        }

        GameEvent.dispatchEvent(GameEvent.MUSOU_FIGHTER_UPDATE);
    }

    /**
     * 队长。
     *
     * <p>队伍是空的时抛错。</p>
     *
     * @return 下标 0 的角色。
     * @example
     * <listing version="3.0">
     * var leader:MusouFighterVO = data.getLeader();
     * </listing>
     */
    public function getLeader():MusouFighterVO {
        return _fighterTeam[0];
    }

    /**
     * 按 id 取已拥有的角色。
     *
     * @param id 角色 id。
     * @return 角色。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var vo:MusouFighterVO = data.getFighterDataById(id);
     * </listing>
     */
    public function getFighterDataById(id:String):MusouFighterVO {
        for each(var i:MusouFighterVO in _fighterData) {
            if (i.id == id) {
                return i;
            }
        }
        return null;
    }

    /**
     * 当前地图的进度。
     *
     * @return 地图进度。还没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var map:MusouWorldMapPlayerVO = data.getCurrentMap();
     * </listing>
     */
    public function getCurrentMap():MusouWorldMapPlayerVO {
        return getMapById(_currentMapId);
    }

    /**
     * 当前区域的进度。
     *
     * @return 区域进度。地图或区域还没开放时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var area:MusouWorldMapAreaPlayerVO = data.getCurrentArea();
     * </listing>
     */
    public function getCurrentArea():MusouWorldMapAreaPlayerVO {
        var map:MusouWorldMapPlayerVO = getCurrentMap();
        if (!map) {
            return null;
        }

        return map.getOpenArea(_currentAreaId);
    }

    /**
     * 改当前区域 id。不检查这个区域是否已经开放。
     *
     * @param areaId 区域 id。
     * @example
     * <listing version="3.0">
     * data.setCurrentArea(id);
     * </listing>
     */
    public function setCurrentArea(areaId:String):void {
        _currentAreaId = areaId;
    }

    /**
     * 在当前地图上按 id 取区域进度。
     *
     * @param id 区域 id。
     * @return 区域进度。地图不存在或区域没开放时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var area:MusouWorldMapAreaPlayerVO = data.getCurrentMapAreaById(id);
     * </listing>
     */
    public function getCurrentMapAreaById(id:String):MusouWorldMapAreaPlayerVO {
        var map:MusouWorldMapPlayerVO = getCurrentMap();
        if (!map) {
            return null;
        }
        return map.getOpenArea(id);
    }

    /**
     * 按 id 取地图进度。
     *
     * @param id 地图 id。
     * @return 地图进度。没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var map:MusouWorldMapPlayerVO = data.getMapById(id);
     * </listing>
     */
    public function getMapById(id:String):MusouWorldMapPlayerVO {
        for each(var i:MusouWorldMapPlayerVO in _mapData) {
            if (i.id == id) {
                return i;
            }
        }
        return null;
    }

    /**
     * 当前的钱。
     *
     * @return 钱。
     * @example
     * <listing version="3.0">
     * var money:int = data.getMoney();
     * </listing>
     */
    public function getMoney():int {
        return _money.getValue();
    }

    /**
     * 加钱并派更新。负数会把钱减下去，不设下限。
     *
     * @param v 增加的钱。
     * @example
     * <listing version="3.0">
     * data.addMoney(500);
     * </listing>
     */
    public function addMoney(v:int):void {
        var vv:int = _money.getValue() + v;
        _money.setValue(vv);

        GameEvent.dispatchEvent(GameEvent.MONEY_UPDATE);
    }

    /**
     * 花钱并派更新。结果小于 0 时改成 0。
     *
     * @param v 花掉的钱。
     * @example
     * <listing version="3.0">
     * data.loseMoney(500);
     * </listing>
     */
    public function loseMoney(v:int):void {
        var vv:int = _money.getValue() - v;
        if (vv < 0) {
            vv = 0;
        }
        _money.setValue(vv);

        GameEvent.dispatchEvent(GameEvent.MONEY_UPDATE);
    }

    /**
     * 给出战队伍加经验。队长是双倍，其余人是原数。
     *
     * <p>某一格是 <code>null</code> 时抛错。</p>
     *
     * @param v 基础经验。
     * @example
     * <listing version="3.0">
     * data.addFighterExp(100);
     * </listing>
     */
    public function addFighterExp(v:int):void {
        for (var i:int; i < _fighterTeam.length; i++) {
            if (i == 0) {
                _fighterTeam[i].addExp(v * 2);
            }
            else {
                _fighterTeam[i].addExp(v);
            }
        }
    }

    /**
     * 写下用户，并把登录时间记成当前毫秒的 <code>int</code>。
     *
     * @param userId 用户 id。默认 <code>null</code>。
     * @param userName 用户名。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * data.login(id, name);
     * </listing>
     */
    public function login(userId:String = null, userName:String = null):void {
        this.userId   = userId;
        this.userName = userName;

        var date:int = int(new Date().getTime());
        _lastLogin.setValue(date);
    }

    /**
     * 存用户、钱、地图、角色、当前地图和队伍 id。
     *
     * @return 存档对象。
     * @example
     * <listing version="3.0">
     * var o:Object = data.toSaveObj();
     * </listing>
     */
    public function toSaveObj():Object {
        var i:int, d:Object;
        var o:Object = {};
        o.userId     = userId;
        o.userName   = userName;
        o.money      = _money.getValue();

        o.lastLogin = _lastLogin.getValue();


        o.mapData = [];
        for (i = 0; i < _mapData.length; i++) {
            d = _mapData[i].toSaveObj();
            o.mapData.push(d);
        }

        o.fighterData = [];
        for (i = 0; i < _fighterData.length; i++) {
            d = _fighterData[i].toSaveObj();
            o.fighterData.push(d);
        }

        o.currentMapId  = _currentMapId;
        o.currentAreaId = _currentAreaId;

        o.fighterTeam = [];
        for (i = 0; i < _fighterTeam.length; i++) {
            o.fighterTeam.push(_fighterTeam[i].id);
        }

        return o;
    }

    /**
     * 读存档。钱和登录时间为 0 时跳过。队伍里没有的角色 id 不放进队伍。
     *
     * @param o 存档对象。为空时抛错。
     * @example
     * <listing version="3.0">
     * data.readSaveObj(o);
     * </listing>
     */
    public function readSaveObj(o:Object):void {
        var i:int, d:Object;
        var mv:MusouWorldMapPlayerVO;
        var fv:MusouFighterVO;

        userId   = o.userId;
        userName = o.userName;

        if (o.money) {
            _money.setValue(o.money);
        }

        if (o.lastLogin) {
            _lastLogin.setValue(o.lastLogin);
        }

        if (o.mapData) {
            _mapData = new Vector.<MusouWorldMapPlayerVO>();

            for (i = 0; i < o.mapData.length; i++) {
                d  = o.mapData[i];
                mv = new MusouWorldMapPlayerVO();
                mv.readSaveObj(d);
                _mapData.push(mv);
            }
        }

        if (o.fighterData) {
            _fighterData = new Vector.<MusouFighterVO>();
            for (i = 0; i < o.fighterData.length; i++) {
                d  = o.fighterData[i];
                fv = new MusouFighterVO();
                fv.readSaveObj(d);
                _fighterData.push(fv);
            }
        }

        if (o.currentMapId) {
            _currentMapId = o.currentMapId;
        }
        if (o.currentAreaId) {
            _currentAreaId = o.currentAreaId;
        }

        if (o.fighterTeam) {
            _fighterTeam = new Vector.<MusouFighterVO>();

            for (i = 0; i < o.fighterTeam.length; i++) {
                var id:String = o.fighterTeam[i];
                fv            = getFighterDataById(id);
                if (fv) {
                    _fighterTeam.push(fv);
                }
            }
        }

    }

    /** @private */
    private function initMap():void {
        TraceLang('musou_player_data.init_map');

        var map:MusouWorldMapPlayerVO = new MusouWorldMapPlayerVO();
        map.id                        = _currentMapId;
        _mapData.push(map);

        var map2:MusouWorldMapVO = MusouModel.I.getMap(map.id);

        for each(var m:MusouWorldMapAreaVO in map2.areas) {
            if (!m.preOpens || m.preOpens.length < 1) {
                TraceLang('musou_logic.open_map_area', {areaId: m.id});
                map.openArea(m.id);
            }
        }

    }
}
}
