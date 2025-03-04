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

package net.play5d.game.bvn.ctrler.game_stage_loader {
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.setTimeout;

import net.play5d.game.bvn.ctrler.GameLoader;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.vos.BgmVO;
import net.play5d.game.bvn.data.DefinedClass;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.FighterVO;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.MapVO;

public class GameStageLoadCtrl extends EventDispatcher {
    include '../../../../../../../include/_INCLUDE_.as';

    // 是否忽略旧版角色
    public static var IGNORE_OLD_FIGHTER:Boolean = false;
    private static var _i:GameStageLoadCtrl;

    public static function get I():GameStageLoadCtrl {
        _i ||= new GameStageLoadCtrl();
        return _i;
    }
    private var _loadingType:int;

    private var _fighterCache:Object;
    private var _assisterCache:Object;
    private var _mapCache:Object;

    private var _processCallBack:Function;
    private var _errorCallBack:Function;

    private var _loadStep:int;
    private var _loadStepLength:int;

    private var _curLoadStep:int;
    private var _curLoadStepLength:int;

    private var _curLoadName:String;

    ////

    private var _loadMapDatas:Vector.<MapVO>;
    private var _loadFighterDatas:Vector.<FighterVO>;
    private var _loadAssisterDatas:Vector.<FighterVO>;
    private var _loadBgmDatas:Vector.<BgmVO>;

    private var _loadFinishBack:Function;

    public function init(processCallBack:Function = null, errorCallBack:Function = null):void {
        _fighterCache  = {};
        _assisterCache = {};
        _mapCache      = {};

        _loadStep    = 0;
        _curLoadStep = 0;

        _processCallBack = processCallBack;
        _errorCallBack   = errorCallBack;
    }

    public function dispose():void {
        _fighterCache  = null;
        _assisterCache = null;
        _mapCache      = null;
    }


    public function getFighterMc(fileUrl:String, playerId:String):MovieClip {
        var obj:Object = _fighterCache[fileUrl];

        var domain:ApplicationDomain = obj.domain;
        if (!domain) {
            return null;
        }

        try {
            var cls:Class = domain.getDefinition(DefinedClass.MC_MAIN) as Class;
            return new cls();
        }
        catch (e:Error) {

            if (playerId == '1' && obj.mc != null) {
                return obj.mc;
            }
            else {
                return obj.mcSlave;
            }

            throw new Error(
                    GetLang('debug.error.data.game_stage_load_ctrl.not_find_main_mc', fileUrl, DefinedClass.MC_MAIN));
        }

        return null;
    }

    public function getAssisterMc(fileUrl:String, playerId:String):MovieClip {
        var obj:Object = _assisterCache[fileUrl];

        var domain:ApplicationDomain = obj.domain;
        if (!domain) {
            return null;
        }

        try {
            var cls:Class = domain.getDefinition(DefinedClass.MC_MAIN) as Class;
            return new cls();
        }
        catch (e:Error) {

            if (playerId == '1' && obj.mc != null) {
                return obj.mc;
            }
            else {
                return obj.mcSlave;
            }

            throw new Error(
                    GetLang('debug.error.data.game_stage_load_ctrl.not_find_main_mc', fileUrl, DefinedClass.MC_MAIN));
        }

        return null;
    }

    public function getMapMc(fileUrl:String):MovieClip {
        return _mapCache[fileUrl];
    }


    /**
     * 加载游戏所有素材，所有参数均为String数组，可以为NULL
     * @param maps
     * @param fighters
     * @param assisters
     * @param bgms
     *
     */
    public function loadGame(maps:Array, fighters:Array, assisters:Array, bgms:Array, finishBack:Function = null):void {
        _loadStep       = 0;
        _loadStepLength = 0;

        var mapDatas:Vector.<MapVO>          = null;
        var fighterDatas:Vector.<FighterVO>  = null;
        var assisterDatas:Vector.<FighterVO> = null;
        var bgmDatas:Vector.<BgmVO>          = null;

        var id:String;

        _loadStepLength++;
        if (maps) {
            maps     = unique(maps);
            mapDatas = new Vector.<MapVO>();

            for each(id in maps) {
                var mv:MapVO = MapModel.I.getMap(id);
                if (!mv) {
                    throw new Error(GetLang('debug.error.data.game_stage_load_ctrl.get_map_data_fail'));
                }
                mapDatas.push(mv);
            }
        }


        _loadStepLength++;
        if (fighters) {
            fighters     = unique(fighters);
            fighterDatas = new Vector.<FighterVO>();

            for each(id in fighters) {
                var fv:FighterVO = FighterModel.I.getFighter(id);
                if (!fv) {
                    throw new Error(GetLang('debug.error.data.game_stage_load_ctrl.get_fighter_data_fail'));
                }
                fighterDatas.push(fv);
            }
        }

        _loadStepLength++;
        if (assisters) {
            assisters     = unique(assisters);
            assisterDatas = new Vector.<FighterVO>();

            for each(id in assisters) {
                var av:FighterVO = AssisterModel.I.getAssister(id);
                if (!av) {
                    throw new Error(GetLang('debug.error.data.game_stage_load_ctrl.get_assistant_data_fail'));
                }
                assisterDatas.push(av);
            }
        }

        _loadStepLength++;
        if (bgms) {
            bgms     = unique(bgms);
            bgmDatas = new Vector.<BgmVO>();

            for each(id in bgms) {
                var bv:BgmVO = FighterModel.I.getFighterBGM(id);
                if (!bv) {
                    bv = MapModel.I.getMapBGM(id);
                }
                if (!bv) {
                    bv = FighterModel.I.getFighterBGM(id);
                }
                if (!bv) {
                    bv = FighterModel.I.getBossBGM(id);
                }
                if (bv) {
                    bgmDatas.push(bv);
                }
            }
        }

        ///////////////////////////////////////////////////////////////////////

        _loadMapDatas      = mapDatas;
        _loadFighterDatas  = fighterDatas;
        _loadAssisterDatas = assisterDatas;
        _loadBgmDatas      = bgmDatas;

        _loadFinishBack = finishBack;

        _loadStep = 1;

        setTimeout(startLoadingMaps, 300);

//			loadMaps(convertLoadAssets(mapDatas, {id:"id", name: "name", url: "fileUrl"}), function():void{
//
//				loadFighters(convertLoadAssets(fighterDatas, {id:"id", name: "name", url: "fileUrl"}),
// function():void{  loadAssisters(convertLoadAssets(assisterDatas, {id:"id", name: "name", url: "fileUrl"}),
// function():void{  loadBgms(bgmDatas, function():void{ trace("All Finish"); if(finishBack != null) finishBack(); });
// }); }); });

    }

    private function startLoadingMaps():void {
        loadMaps(convertLoadAssets(_loadMapDatas, {id: 'id', name: 'name', url: 'fileUrl'}), function ():void {
            setTimeout(startloadFighters, 100);
        });
    }

    private function startloadFighters():void {
        loadFighters(convertLoadAssets(_loadFighterDatas, {id: 'id', name: 'name', url: 'fileUrl'}), function ():void {
            setTimeout(startloadAssisters, 100);
        });
    }

    private function startloadAssisters():void {
        loadAssisters(
                convertLoadAssets(_loadAssisterDatas, {id: 'id', name: 'name', url: 'fileUrl'}), function ():void {
                    setTimeout(startloadBGM, 100);
                });
    }

    private function startloadBGM():void {
        loadBgms(_loadBgmDatas, function ():void {
            TraceLang('debug.trace.data.game_stage_load_ctrl.load_all_finish');
            if (_loadFinishBack != null) {
                _loadFinishBack();
                _loadFinishBack = null;
            }
        });
    }

    private function loadMaps(maps:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, succBack:Function):void {
            GameLoader.loadSWF(lv.url, loadSucc, onLoadError, onLoadProcess);

            function loadSucc(l:Loader):void {
                _mapCache[lv.url] = l.content;
                disposeLoader(l);
                succBack();
            }
        }

        _loadingType = GameStageLoadDefine.TYPE_MAP;
        loadAssets(maps, load, callback);
    }

    private function loadFighters(fighters:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, succBack:Function):void {
            function loadSucc(l:Loader):void {
                _fighterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : null
                };
                disposeLoader(l);
                succBack();
            }

            function loadSucc2(l:Loader):void {
                _fighterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : l.content
                };
                disposeLoader(l);
                GameLoader.loadSWF(lv.url, loadSucc3, onLoadError, onLoadProcess);
            }

            function loadSucc3(l:Loader):void {
                _fighterCache[lv.url].mcSlave = l.content;
                disposeLoader(l);
                succBack();
            }


            if (IGNORE_OLD_FIGHTER) {
                GameLoader.loadSWF(lv.url, loadSucc2, onLoadError, onLoadProcess);
            }
            else {
                GameLoader.loadSWF(lv.url, loadSucc, onLoadError, onLoadProcess);
            }


        }

        _loadingType = GameStageLoadDefine.TYPE_FIGHTER;
        loadAssets(fighters, load, callback);
    }

    private function loadAssisters(assissters:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, succBack:Function):void {

            function loadSucc(l:Loader):void {
                _assisterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : (
                            IGNORE_OLD_FIGHTER ? l.content : null
                    )
                };
                disposeLoader(l);
                succBack();
            }

            function loadSucc2(l:Loader):void {
                _assisterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : l.content
                };
                disposeLoader(l);
                GameLoader.loadSWF(lv.url, loadSucc3, onLoadError, onLoadProcess);
            }

            function loadSucc3(l:Loader):void {
                _assisterCache[lv.url].mcSlave = l.content;
                disposeLoader(l);
                succBack();
            }

            if (IGNORE_OLD_FIGHTER) {
                GameLoader.loadSWF(lv.url, loadSucc2, onLoadError, onLoadProcess);
            }
            else {
                GameLoader.loadSWF(lv.url, loadSucc, onLoadError, onLoadProcess);
            }
        }

        _loadingType = GameStageLoadDefine.TYPE_ASSISTER;
        loadAssets(assissters, load, callback);
    }

    private function loadBgms(bgms:Vector.<BgmVO>, callback:Function):void {
        function succBack():void {
            _loadStep++;
            _curLoadName = null;
            callback();
        }

        if (!bgms) {
            callback();
            return;
        }

        _loadingType       = GameStageLoadDefine.TYPE_BGM;
        _curLoadStep       = 0;
        _curLoadStepLength = 1;
        SoundCtrl.I.loadFightBGM(bgms, succBack, callback, onLoadProcess);
    }

    private function onLoadProcess(v:Number):void {
        var itemName:String;
        switch (_loadingType) {
        case GameStageLoadDefine.TYPE_MAP:
            itemName = GetLangText('txt.game_stage_load_ctrl.map');
            break;
        case GameStageLoadDefine.TYPE_FIGHTER:
            itemName = GetLangText('txt.game_stage_load_ctrl.fighter');
            break;
        case GameStageLoadDefine.TYPE_ASSISTER:
            itemName = GetLangText('txt.game_stage_load_ctrl.assistant');
            break;
        case GameStageLoadDefine.TYPE_BGM:
            itemName = GetLangText('txt.game_stage_load_ctrl.bgm');
            break;
        }

//			var msg:String = "正在加载" + itemName;
//			if(_curLoadName) msg += " : " + _curLoadName;
//
//			msg += " (" + _loadStep + "/" + _loadStepLength + ")";
        var msg:String;
        if (_curLoadName) {
            msg = Format(
                    GetLangText('txt.game_stage_load_ctrl.loading_has_name'), itemName, _curLoadName, _loadStep,
                    _loadStepLength
            );
        }
        else {
            msg = Format(GetLangText('txt.game_stage_load_ctrl.loading_no_name'), itemName, _loadStep, _loadStepLength);
        }

        var val:Number = (
                                 _curLoadStep + v
                         ) / _curLoadStepLength;

        _processCallBack(msg, val);
    }

    private function onLoadError(msg:String):void {
        _errorCallBack(msg);
    }

    private function disposeLoader(l:Loader):void {
        try {
            l.unloadAndStop(true);
        }
        catch (e:Error) {
            try {
                l.unload();
            }
            catch (e2:Error) {
                trace(e2);
            }
            trace(e);
        }
    }


    // 数组去重
    private function unique(arr:Array):Array {
        var hash:Array = [];
        for (var i:int = 0; i < arr.length; i++) {
            if (arr[i] === null || arr[i] === undefined) {
                continue;
            }

            for (var j:int = i + 1; j < arr.length; j++) {
                if (arr[i] == arr[j]) {
                    ++i;
                }
            }
            hash.push(arr[i]);
        }
        return hash;
    }

    // 加载资源主要逻辑
    private function loadAssets(assets:Vector.<LoadAssetVO>, loadFunc:Function, callback:Function):void {
        var currentAsset:LoadAssetVO;

        function loadNext():void {
            if (assets.length < 1) {
                _loadStep++;
                _curLoadName = null;
                callback();
                return;
            }
            var fv:LoadAssetVO = assets.shift();
            currentAsset       = fv;
            _curLoadName       = fv.name;
            //				GameLoader.loadSWF(fv.url, loadSucc, onLoadError, onLoadProcess);

            loadFunc(fv, loadSucess);
        }

        function loadSucess():void {
            _curLoadStep++;
            loadNext();
        }

        if (!assets) {
            callback();
            return;
        }

        _curLoadStep       = 0;
        _curLoadStepLength = assets.length;

        loadNext();
    }

    private function convertLoadAssets(source:*, keyMap:Object):Vector.<LoadAssetVO> {
        var result:Vector.<LoadAssetVO> = new Vector.<LoadAssetVO>();
        var urlMap:Object               = {};
        for each(var i:* in source) {
            var lv:LoadAssetVO = new LoadAssetVO();
            for (var j:String in keyMap) {
                var k:String = keyMap[j];
                lv[j]        = i[k];
            }
            if (urlMap[lv.url]) {
                continue;
            }

            urlMap[lv.url] = lv;
            result.push(lv);
        }
        return result;
    }

}
}

internal class LoadAssetVO {
    public var id:String;
    public var url:String;
    public var name:String;
}
