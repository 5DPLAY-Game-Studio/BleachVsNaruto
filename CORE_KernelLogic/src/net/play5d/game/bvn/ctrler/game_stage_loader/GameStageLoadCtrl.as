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
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 对局素材加载：地图、角色、援助和背景音乐。
 *
 * <p>取角色或援助时，路径不在缓存里会在读 <code>domain</code> 时抛错；条目在但没有 <code>domain</code> 时返回 <code>null</code>。
 * 类定义找不到时，玩家 id 为 <code>1</code> 且缓存了 <code>mc</code> 就返回那一份，否则返回 <code>mcSlave</code>。
 * 地图返回缓存里的同一个显示对象，没有这个路径时为 <code>undefined</code>。
 * <code>loadGame</code> 里地图、角色、援助传 <code>null</code> 时，300 毫秒后开始加载会抛错；空数组可以。背景音乐可以是 <code>null</code>。找不到的曲目会跳过。</p>
 *
 * @see GameStageLoadDefine
 */
public class GameStageLoadCtrl extends EventDispatcher {

    /**
     * 为 <code>true</code> 时，角色和援助会再加载一份，分别放进 <code>mc</code> 和 <code>mcSlave</code>。
     *
     * @default false
     */
    public static var IGNORE_OLD_FIGHTER:Boolean = false;
    /** @private */
    private static var _i:GameStageLoadCtrl;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 对局加载控制。
     * @example
     * <listing version="3.0">
     * GameStageLoadCtrl.I.init(onProgress, onError);
     * </listing>
     */
    public static function get I():GameStageLoadCtrl {
        _i ||= new GameStageLoadCtrl();
        return _i;
    }
    /** @private */
    private var _loadingType:int;

    /** @private */
    private var _fighterCache:Object;
    /** @private */
    private var _assisterCache:Object;
    /** @private */
    private var _mapCache:Object;

    /** @private */
    private var _progressCallBack:Function;
    /** @private */
    private var _errorCallBack:Function;

    /** @private */
    private var _loadStep:int;
    /** @private */
    private var _loadStepLength:int;

    /** @private */
    private var _curLoadStep:int;
    /** @private */
    private var _curLoadStepLength:int;

    /** @private */
    private var _curLoadName:String;

    /** @private */
    private var _loadMapDatas:Vector.<MapVO>;
    /** @private */
    private var _loadFighterDatas:Vector.<FighterVO>;
    /** @private */
    private var _loadAssisterDatas:Vector.<FighterVO>;
    /** @private */
    private var _loadBgmDatas:Vector.<BgmVO>;

    /** @private */
    private var _loadFinishBack:Function;

    /**
     * 清空三类缓存并记下进度、失败回调。
     *
     * <p>进度回调为空时，加载过程中的进度上报会抛错。</p>
     *
     * @param progressCallBack 进度回调，参数是文案和 0 到 1 的进度。可省略。
     * @param errorCallBack 失败回调。可省略。省略后失败上报会抛错。
     * @example
     * <listing version="3.0">
     * GameStageLoadCtrl.I.init(function (msg:String, p:Number):void {}, function (msg:String):void {});
     * </listing>
     */
    public function init(progressCallBack:Function = null, errorCallBack:Function = null):void {
        _fighterCache  = {};
        _assisterCache = {};
        _mapCache      = {};

        _loadStep    = 0;
        _curLoadStep = 0;

        _progressCallBack = progressCallBack;
        _errorCallBack   = errorCallBack;
    }

    /**
     * 丢掉三类缓存。
     *
     * <p>之后再取影片会抛错。</p>
     *
     * @example
     * <listing version="3.0">
     * GameStageLoadCtrl.I.dispose();
     * </listing>
     */
    public function dispose():void {
        _fighterCache  = null;
        _assisterCache = null;
        _mapCache      = null;
    }


    /**
     * 按路径取一个角色影片。
     *
     * <p>路径不在缓存里时抛错。没有域时返回 <code>null</code>。
     * 找不到主时间轴类时，玩家 id 为 <code>1</code> 且缓存了 <code>mc</code> 就返回那一份，否则返回 <code>mcSlave</code>。</p>
     *
     * @param fileUrl 角色 SWF 路径，也是缓存键。
     * @param playerId 玩家 id。<code>1</code> 才会用到 <code>mc</code>。
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var mc:MovieClip = GameStageLoadCtrl.I.getFighterMc(url, '1');
     * </listing>
     */
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
                    GetLang('log.error.load.game_stage_load_ctrl.not_find_main_mc', {
                        fileUrl: fileUrl,
                        mainMc : DefinedClass.MC_MAIN
                    }));
        }

        return null;
    }

    /**
     * 按路径取一个援助影片。规则和角色相同。
     *
     * @param fileUrl 援助 SWF 路径。
     * @param playerId 玩家 id。
     * @return 影片。
     * @example
     * <listing version="3.0">
     * var mc:MovieClip = GameStageLoadCtrl.I.getAssisterMc(url, '1');
     * </listing>
     */
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
                    GetLang('log.error.load.game_stage_load_ctrl.not_find_main_mc', {
                        fileUrl: fileUrl,
                        mainMc : DefinedClass.MC_MAIN
                    }));
        }

        return null;
    }

    /**
     * 取缓存里的地图显示对象。
     *
     * <p>每次返回同一份。路径不在缓存里时为 <code>undefined</code>。缓存被清掉后抛错。</p>
     *
     * @param fileUrl 地图 SWF 路径。
     * @return 显示对象。
     * @example
     * <listing version="3.0">
     * var mc:MovieClip = GameStageLoadCtrl.I.getMapMc(url);
     * </listing>
     */
    public function getMapMc(fileUrl:String):MovieClip {
        return _mapCache[fileUrl];
    }


    /**
     * 按 id 加载一局用到的地图、角色、援助和背景音乐。
     *
     * <p>地图、角色、援助里有找不到的 id 时立刻抛错。背景音乐找不到就跳过。
     * 前三类传 <code>null</code> 时，开始加载后会抛错；空数组可以。结束回调只调用一次。</p>
     *
     * @param maps 地图 id。
     * @param fighters 角色 id。
     * @param assisters 援助 id。
     * @param bgms 曲目 id。可以是 <code>null</code>。
     * @param finishBack 全部结束后的回调。可省略。
     * @example
     * <listing version="3.0">
     * GameStageLoadCtrl.I.loadGame(maps, fighters, assisters, bgms, function ():void {});
     * </listing>
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
                    throw new Error(GetLang('log.error.load.game_stage_load_ctrl.get_map_data_fail'));
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
                    throw new Error(GetLang('log.error.load.game_stage_load_ctrl.get_fighter_data_fail'));
                }
                fighterDatas.push(fv);
            }
        }

        _loadStepLength++;
        if (assisters) {
            assisters     = unique(assisters);
            assisterDatas = new Vector.<FighterVO>();

            for each(id in assisters) {
                var fighterVO:FighterVO = AssisterModel.I.getAssister(id);
                if (!fighterVO) {
                    throw new Error(GetLang('log.error.load.game_stage_load_ctrl.get_assistant_data_fail'));
                }
                assisterDatas.push(fighterVO);
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
            TraceLang('game_stage_load_ctrl.load_all_finish');
            if (_loadFinishBack != null) {
                _loadFinishBack();
                _loadFinishBack = null;
            }
        });
    }

    private function loadMaps(maps:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, successBack:Function):void {
            GameLoader.loadSWF(lv.url, loadSuccess, onLoadError, onLoadProgress);

            function loadSuccess(l:Loader):void {
                _mapCache[lv.url] = l.content;
                disposeLoader(l);
                successBack();
            }
        }

        _loadingType = GameStageLoadDefine.TYPE_MAP;
        loadAssets(maps, load, callback);
    }

    private function loadFighters(fighters:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, successBack:Function):void {
            function loadSuccess(l:Loader):void {
                _fighterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : null
                };
                disposeLoader(l);
                successBack();
            }

            function loadSuccess2(l:Loader):void {
                _fighterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : l.content
                };
                disposeLoader(l);
                GameLoader.loadSWF(lv.url, loadSuccess3, onLoadError, onLoadProgress);
            }

            function loadSuccess3(l:Loader):void {
                _fighterCache[lv.url].mcSlave = l.content;
                disposeLoader(l);
                successBack();
            }


            if (IGNORE_OLD_FIGHTER) {
                GameLoader.loadSWF(lv.url, loadSuccess2, onLoadError, onLoadProgress);
            }
            else {
                GameLoader.loadSWF(lv.url, loadSuccess, onLoadError, onLoadProgress);
            }


        }

        _loadingType = GameStageLoadDefine.TYPE_FIGHTER;
        loadAssets(fighters, load, callback);
    }

    private function loadAssisters(assissters:Vector.<LoadAssetVO>, callback:Function):void {
        function load(lv:LoadAssetVO, successBack:Function):void {

            function loadSuccess(l:Loader):void {
                _assisterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : (
                            IGNORE_OLD_FIGHTER ? l.content : null
                    )
                };
                disposeLoader(l);
                successBack();
            }

            function loadSuccess2(l:Loader):void {
                _assisterCache[lv.url] = {
                    domain: l.contentLoaderInfo.applicationDomain,
                    mc    : l.content
                };
                disposeLoader(l);
                GameLoader.loadSWF(lv.url, loadSuccess3, onLoadError, onLoadProgress);
            }

            function loadSuccess3(l:Loader):void {
                _assisterCache[lv.url].mcSlave = l.content;
                disposeLoader(l);
                successBack();
            }

            if (IGNORE_OLD_FIGHTER) {
                GameLoader.loadSWF(lv.url, loadSuccess2, onLoadError, onLoadProgress);
            }
            else {
                GameLoader.loadSWF(lv.url, loadSuccess, onLoadError, onLoadProgress);
            }
        }

        _loadingType = GameStageLoadDefine.TYPE_ASSISTER;
        loadAssets(assissters, load, callback);
    }

    private function loadBgms(bgms:Vector.<BgmVO>, callback:Function):void {
        function successBack():void {
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
        SoundCtrl.I.loadFightBGM(bgms, successBack, callback, onLoadProgress);
    }

    private function onLoadProgress(v:Number):void {
        var itemName:String;
        switch (_loadingType) {
        case GameStageLoadDefine.TYPE_MAP:
            itemName = GetLang('loading.map');
            break;
        case GameStageLoadDefine.TYPE_FIGHTER:
            itemName = GetLang('loading.fighter');
            break;
        case GameStageLoadDefine.TYPE_ASSISTER:
            itemName = GetLang('loading.assistant');
            break;
        case GameStageLoadDefine.TYPE_BGM:
            itemName = GetLang('loading.bgm');
            break;
        }

        var msg:String;
        if (_curLoadName) {
            msg = GetLang('loading.has_name', {
                itemName  : itemName,
                loadName  : _curLoadName,
                step      : _loadStep,
                stepLength: _loadStepLength
            });
        }
        else {
            msg = GetLang('loading.no_name', {
                itemName  : itemName,
                step      : _loadStep,
                stepLength: _loadStepLength
            });
        }

        var val:Number = (
                                 _curLoadStep + v
                         ) / _curLoadStepLength;

        _progressCallBack(msg, val);
    }

    private function onLoadError(msg:String):void {
        _errorCallBack(msg);
    }

    private static function disposeLoader(l:Loader):void {
        try {
            l.unloadAndStop(true);
        }
        catch (e:Error) {
            try {
                l.unload();
            }
            catch (e2:Error) {
                GameLogger.error('load', String(e2));
            }
            GameLogger.error('load', String(e));
        }
    }


    // 数组去重
    private static function unique(arr:Array):Array {
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

            loadFunc(fv, loadSuccess);
        }

        function loadSuccess():void {
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

    private static function convertLoadAssets(source:*, keyMap:Object):Vector.<LoadAssetVO> {
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

/**
 * 加载条目。
 *
 * @private
 */
internal class LoadAssetVO {
    /** @private */
    public var id:String;
    /** @private */
    public var url:String;
    /** @private */
    public var name:String;
}
