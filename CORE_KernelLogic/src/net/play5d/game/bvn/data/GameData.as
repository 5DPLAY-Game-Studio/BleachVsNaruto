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
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.musou.MusouFighterModel;
import net.play5d.game.bvn.data.musou.MusouFighterSellVO;
import net.play5d.game.bvn.data.musou.MusouMissionVO;
import net.play5d.game.bvn.data.musou.MusouModel;
import net.play5d.game.bvn.data.musou.MusouWorldMapAreaVO;
import net.play5d.game.bvn.data.musou.MusouWorldMapVO;
import net.play5d.game.bvn.data.musou.player.MusouPlayerData;
import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.data.vos.MessionStageVO;
import net.play5d.game.bvn.data.vos.MessionVO;
import net.play5d.game.bvn.data.vos.SelectCharListItemVO;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.interfaces.GameInterface;

public class GameData {

    private const SAVE_ID:String = 'bvn3.5A';
    // 是否启动无双模式的数据保存
    private const __MUSOU_DATA_ENABLED:Boolean = true;
    private static var _i:GameData;

    public static function get I():GameData {
        _i ||= new GameData();
        return _i;
    }

    public var config:ConfigVO           = new ConfigVO();
    public var musouData:MusouPlayerData = new MusouPlayerData();
    public var p1Select:SelectVO;
    public var p2Select:SelectVO;
    public var selectMap:String;
    public var score:int = 0;
    public var winnerId:String;

//		private const __MUSOU_DATA_ENABLED:Boolean = false;
    public var isFristRun:Boolean = true;

    public function loadConfig(back:Function, fail:Function = null):void {

        PackRegistry.I.load(loadPacksBack, failWith('txt.game_data.load_fighter_fail'));

        function loadPacksBack():void {
            AssetManager.I.loadJSON('config/select.json', loadSelectBack, failWith('txt.game_data.load_select_fail'));
        }

        function loadSelectBack(data:Object):void {
            config.select_config.initByObject(data);
            AssetManager.I.loadJSON('config/map.json', loadMapBack, failWith('txt.game_data.load_map_fail'));
        }

        function loadMapBack(data:Object):void {
            MapModel.I.initByObject(data);
            AssetManager.I.loadJSON('config/mission.json', loadMissionBack, failWith('txt.game_data.load_mission_fail'));
        }

        function loadMissionBack(data:Object):void {
            MessionModel.I.initByObject(data);

            MusouModel.I.loadMapData(loadMusouDataBack, failWith('txt.game_data.load_musou_fail'));
        }

        function loadMusouDataBack():void {
            MusouFighterModel.I.init();

            validateSelect();
            validateMissionData();
            validateMusouData();

            if (back != null) {
                back();
            }
        }

        function failWith(langKey:String):Function {
            return function ():void {
                var msg:String = GetLang(langKey);
                Debugger.log(msg);
                if (fail != null) {
                    fail(msg);
                }
            };
        }

    }

    public function initData():void {
        musouData.init();
//			GameData.I.loadSaveData();
    }

    public function saveData():void {
        var o:Object = {};
        o.id         = SAVE_ID;

        o.config = config.toSaveObj();
        o.musou  = musouData.toSaveObj();


        GameInterface.instance.saveGame(o);
    }

    public function loadSaveData():void {
        var o:Object = GameInterface.instance.loadGame();
        if (!o || o.id != SAVE_ID) {
            return;
        }

//			trace('loadSaveData', JSON.stringify(o));

        if (o.config) {
            config.readSaveObj(o.config);
        }

        if (o.musou && __MUSOU_DATA_ENABLED) {
            musouData.readSaveObj(o.musou);
        }
    }

    public function loadSelect(url:String):void {
        AssetManager.I.loadJSON(url, function (data:Object):void {
            setSelectData(data);
        }, function ():void {
            TraceLang('debug.trace.data.game_data.load_select_error');
        });
    }

    public function setSelectData(data:Object):void {
        config.select_config.initByObject(data);
    }

    // 验证选人（缺失软降级：空槽 / 过滤 more，不抛错）
    private function validateSelect():void {
        var missFighters:Array  = [];
        var missAssisters:Array = [];

        var s:SelectCharListItemVO;
        var f:String;
        var fighter:FighterVO;
        for each(s in config.select_config.charList.list) {
            if (s.fighterID && !FighterModel.I.getFighter(s.fighterID)) {
                if (missFighters.indexOf(s.fighterID) == -1) {
                    missFighters.push(s.fighterID);
                }
                s.fighterID = null;
            }
            s.moreFighterIDs = filterExistingIds(s.moreFighterIDs, false, missFighters);

            for each(f in s.getAllFighterIDs()) {
                fighter = FighterModel.I.getFighter(f);
                if (fighter == null && missFighters.indexOf(f) == -1) {
                    missFighters.push(f);
                }
            }
        }

        for each(s in config.select_config.assistList.list) {
            if (s.fighterID && !AssisterModel.I.getAssister(s.fighterID)) {
                if (missAssisters.indexOf(s.fighterID) == -1) {
                    missAssisters.push(s.fighterID);
                }
                s.fighterID = null;
            }
            s.moreFighterIDs = filterExistingIds(s.moreFighterIDs, true, missAssisters);

            for each(f in s.getAllFighterIDs()) {
                fighter = AssisterModel.I.getAssister(f);
                if (fighter == null && missAssisters.indexOf(f) == -1) {
                    missAssisters.push(f);
                }
            }
        }

        if (missFighters.length > 0 || missAssisters.length > 0) {
            var msg:String = '';
            if (missFighters.length > 0) {
                msg += 'fighter : ' + missFighters.join(' , ') + ' ; ';
            }
            if (missAssisters.length > 0) {
                msg += 'assister : ' + missAssisters.join(' , ') + ' ; ';
            }
            Debugger.log(GetLang('debug.error.data.game_data.verify_select_fail', {file: 'select.json', message: msg}));
        }
    }

    /**
     * 过滤仍存在于模型中的 id 列表。
     *
     * @param ids       原 id 数组。
     * @param assister  是否按援助模型查。
     * @param missOut   缺失 id 汇总。
     * @return 过滤后数组；全无则 <code>null</code>。
     */
    private function filterExistingIds(ids:Array, assister:Boolean, missOut:Array):Array {
        if (!ids || ids.length < 1) {
            return ids;
        }

        var kept:Array = [];
        for each (var id:String in ids) {
            if (!id) {
                continue;
            }
            var ok:Boolean = assister ? AssisterModel.I.getAssister(id) != null : FighterModel.I.getFighter(id) != null;
            if (ok) {
                kept.push(id);
            }
            else if (missOut.indexOf(id) == -1) {
                missOut.push(id);
            }
        }

        return kept.length > 0 ? kept : null;
    }

    // 验证关卡（缺失软降级：跳过缺角 id，不抛错）
    private function validateMissionData():void {
        var missFighters:Array  = [];
        var missMaps:Array      = [];
        var missAssisters:Array = [];

        var missions:Array = MessionModel.I.getAllMissions();
        for each(var m:MessionVO in missions) {
            var ms:Vector.<MessionStageVO> = m.stageList;
            for each(var s:MessionStageVO in ms) {

                if (s.fighters) {
                    var kept:Array = [];
                    for each(var f:String in s.fighters) {
                        var fighter:FighterVO = FighterModel.I.getFighter(f);
                        if (fighter == null) {
                            if (missFighters.indexOf(f) == -1) {
                                missFighters.push(f);
                            }
                        }
                        else {
                            kept.push(f);
                        }
                    }
                    s.fighters = kept;
                }

                var map:MapVO = MapModel.I.getMap(s.map);
                if (map == null) {
                    if (missMaps.indexOf(s.map) == -1) {
                        missMaps.push(s.map);
                    }
                }

                if (s.assister) {
                    var assister:FighterVO = AssisterModel.I.getAssister(s.assister);
                    if (assister == null) {
                        if (missAssisters.indexOf(s.assister) == -1) {
                            missAssisters.push(s.assister);
                        }
                        s.assister = null;
                    }
                }

            }
        }


        if (missFighters.length > 0 || missAssisters.length > 0 || missMaps.length > 0) {
            var msg:String = '';
            if (missFighters.length > 0) {
                msg += 'fighter : ' + missFighters.join(' , ') + ' ; ';
            }
            if (missAssisters.length > 0) {
                msg += 'assister : ' + missAssisters.join(' , ') + ' ; ';
            }
            if (missMaps.length > 0) {
                msg += 'map : ' + missMaps.join(' , ') + ' ; ';
            }
            Debugger.log(GetLang('debug.error.data.game_data.verify_mission_fail', {file: 'mission.json', message: msg}));
        }
    }

    // 验证无双关卡（缺失软降级：仅日志，不抛错）
    private function validateMusouData():void {
        var mapObj:Object = MusouModel.I.getAllMap();

        for (var i:String in mapObj) {

            var mwv:MusouWorldMapVO = mapObj[i];

            for each(var a:MusouWorldMapAreaVO in mwv.areas) {
                for each(var mv:MusouMissionVO in a.missions) {

                    var musouId:String = mwv.id + ' - ' + a.id + ' - ' + mv.id;


                    var map:MapVO = MapModel.I.getMap(mv.map);
                    if (map == null) {
                        Debugger.log(
                                GetLang('debug.error.data.game_data.verify_musou_fail', {
                                    musouId: musouId,
                                    type   : 'map',
                                    value  : mv.map
                                }));
                    }

                    var ememies:Array = mv.getAllEnemieIds();
                    for each(var f:String in ememies) {
                        var fighter:FighterVO = FighterModel.I.getFighter(f);
                        if (fighter == null) {
                            Debugger.log(
                                    GetLang('debug.error.data.game_data.verify_musou_fail', {
                                        musouId: musouId,
                                        type   : 'fighter',
                                        value  : f
                                    }));
                        }
                    }

                }
            }

        }


        var missFighters:Array = [];

        var fighters:Vector.<MusouFighterSellVO> = MusouFighterModel.I.fighters;
        for each(var s:MusouFighterSellVO in fighters) {
            var fv:FighterVO = FighterModel.I.getFighter(s.id);
            if (!fv && missFighters.indexOf(s.id) == -1) {
                missFighters.push(s.id);
            }
        }

        if (missFighters.length > 0) {
            var msg:String = '';
            msg += 'fighter : ' + missFighters.join(' , ') + ' ; ';
            Debugger.log(GetLang('debug.error.data.game_data.verify_fighter_model_fail', {message: msg}));
        }

    }

}
}
