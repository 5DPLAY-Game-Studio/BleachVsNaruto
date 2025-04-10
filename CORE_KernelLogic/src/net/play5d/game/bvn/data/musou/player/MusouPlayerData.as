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
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouLogic;
import net.play5d.game.bvn.data.ISaveData;
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.MusouWorldMapAreaVO;
import net.play5d.game.bvn.data.musou.MusouWorldMapVO;
import net.play5d.game.bvn.data.musou.utils.MusouFighterFactory;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.utils.WrapInteger;

public class MusouPlayerData implements ISaveData {
    include '../../../../../../../../include/_INCLUDE_.as';

    public function MusouPlayerData() {

    }
    public var userId:String;
    public var userName:String;
    private var _money:WrapInteger                      = new WrapInteger(0);
    private var _mapData:Vector.<MusouWorldMapPlayerVO> = new Vector.<MusouWorldMapPlayerVO>();
    private var _fighterData:Vector.<MusouFighterVO>    = new Vector.<MusouFighterVO>(); //拥有的角色
    private var _fighterTeam:Vector.<MusouFighterVO>    = new Vector.<MusouFighterVO>(); //参战的角色
    private var _lastLogin:WrapInteger                  = new WrapInteger(0);
    private var _currentMapId:String                    = 'map1';
    private var _currentAreaId:String                   = 'p1';

    public function init():void {
        initMap();

        _money.setValue(3000);

        _fighterData.push(MusouFighterFactory.create('ichigo'));
        _fighterData.push(MusouFighterFactory.create('naruto'));
        _fighterData.push(MusouFighterFactory.create('sakura'));

        _fighterTeam = _fighterData.concat();
    }

    public function getFighterData():Vector.<MusouFighterVO> {
        return _fighterData;
    }

    public function addFighter(id:String):MusouFighterVO {
        var fv:MusouFighterVO = getFighterDataById(id);

        if (fv) {
            return fv;
        }

        fv = MusouFighterFactory.create(id);
        _fighterData.push(fv);

        return fv;
    }

    public function getFighterTeam():Vector.<MusouFighterVO> {
        return _fighterTeam;
    }

    public function getFighterTeamIds():Array {
        var ids:Array = [];
        for (var i:int; i < _fighterTeam.length; i++) {
            ids.push(_fighterTeam[i].id);
        }
        return ids;
    }

    public function setFighterTeam(index:int, id:String):void {
        var mv:MusouFighterVO = getFighterDataById(id);
        if (!mv) {
            return;
        }
        _fighterTeam[index] = mv;

        GameEvent.dispatchEvent(GameEvent.MOSOU_FIGHTER_UPDATE);
    }

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

        GameEvent.dispatchEvent(GameEvent.MOSOU_FIGHTER_UPDATE);
    }

    public function getLeader():MusouFighterVO {
        return _fighterTeam[0];
    }

    public function getFighterDataById(id:String):MusouFighterVO {
        for each(var i:MusouFighterVO in _fighterData) {
            if (i.id == id) {
                return i;
            }
        }
        return null;
    }

    public function getCurrentMap():MusouWorldMapPlayerVO {
        return getMapById(_currentMapId);
    }

    public function getCurrentArea():MusouWorldMapAreaPlayerVO {
        var map:MusouWorldMapPlayerVO = getCurrentMap();
        if (!map) {
            return null;
        }

        return map.getOpenArea(_currentAreaId);
    }

    public function setCurrentArea(areaId:String):void {
        _currentAreaId = areaId;
    }

    public function getCurrentMapAreaById(id:String):MusouWorldMapAreaPlayerVO {
        var map:MusouWorldMapPlayerVO = getCurrentMap();
        if (!map) {
            return null;
        }
        return map.getOpenArea(id);
    }

    public function getMapById(id:String):MusouWorldMapPlayerVO {
        for each(var i:MusouWorldMapPlayerVO in _mapData) {
            if (i.id == id) {
                return i;
            }
        }
        return null;
    }

    public function getMoney():int {
        return _money.getValue();
    }

    public function addMoney(v:int):void {
        var vv:int = _money.getValue() + v;
        _money.setValue(vv);

        GameEvent.dispatchEvent(GameEvent.MONEY_UPDATE);
    }

    public function loseMoney(v:int):void {
        var vv:int = _money.getValue() - v;
        if (vv < 0) {
            vv = 0;
        }
        _money.setValue(vv);

        GameEvent.dispatchEvent(GameEvent.MONEY_UPDATE);
    }

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

    public function login(userId:String = null, userName:String = null):void {
        this.userId   = userId;
        this.userName = userName;

        var date:int = int(new Date().getTime());
        _lastLogin.setValue(date);
    }

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

    private function initMap():void {
        TraceLang('debug.trace.data.musou_player_data.init_map');

        var map:MusouWorldMapPlayerVO = new MusouWorldMapPlayerVO();
        map.id                        = _currentMapId;
        _mapData.push(map);

        var map2:MusouWorldMapVO = MusouModel.I.getMap(map.id);

        for each(var m:MusouWorldMapAreaVO in map2.areas) {
            if (!m.preOpens || m.preOpens.length < 1) {
                MusouLogic.I.openMapArea(map.id, m.id);
            }
        }

    }
}
}
