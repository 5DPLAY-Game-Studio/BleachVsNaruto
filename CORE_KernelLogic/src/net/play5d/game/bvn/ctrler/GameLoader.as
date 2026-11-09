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

package net.play5d.game.bvn.ctrler {
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.system.ApplicationDomain;

import net.play5d.game.bvn.data.AssisterModel;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.MapModel;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 按 id 加载角色、援助和地图的 SWF，并缓存角色。
 *
 * <p>角色缓存命中时，<code>loadAndCacheFighter</code> 的回调不带参数；<code>loadFighter</code> 的回调带新建的角色。
 * id 不存在时走失败回调，参数是一句加载文案。SWF 里没有 <code>main_mc</code> 时仍会缓存，之后用 <code>loader.content</code> 当影片。
 * <code>dispose</code> 先把缓存字段置空，再卸载已经记下的 Loader；正在进行的加载不会取消。</p>
 *
 * @see AssetManager
 */
public class GameLoader {

    /** @private */
    private static var _fighterCache:Object = {};

    /** @private */
    private static var _loadedSwfCache:Vector.<Loader> = new Vector.<Loader>();

    /**
     * 加载并缓存角色 SWF。已经缓存时直接回调。
     *
     * @param fighterId 角色 id。
     * @param back 成功回调，不带参数。
     * @param fail 失败回调，参数是一句文案。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * GameLoader.loadAndCacheFighter(id, function ():void {}, function (msg:String):void {});
     * </listing>
     */
    public static function loadAndCacheFighter(fighterId:String, back:Function, fail:Function = null,
                                               progress:Function                               = null
    ):void {
        if (_fighterCache[fighterId]) {
            if (back != null) {
                back();
            }
            return;
        }


        var fv:FighterVO = FighterModel.I.getFighter(fighterId, true);
        if (!fv) {
            TraceLang('game_loader.fighter_id_error', {fighterId: fighterId});
            if (fail != null) {
                fail(GetLang('loading.fighter_id_error'));
            }
            return;
        }

        loadSWF(fv.fileUrl, loadComplete, fail, progress);

        function loadComplete(loader:Loader):void {
            var cachevo:FighterCacheVO = new FighterCacheVO();
            cachevo.loader             = loader;
            cachevo.fighterData        = fv;

            _fighterCache[fighterId] = cachevo;

            try {
                var domain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
                var mainMcClass:Object       = domain.getDefinition('main_mc');
                cachevo.MainClass            = mainMcClass as Class;
            }
            catch (e:Error) {
                TraceLang('game_loader.fighter_load_error', {error: e});
            }

            if (back != null) {
                back();
            }
        }
    }

    /**
     * 取缓存角色；没有缓存时先加载再回调。
     *
     * @param fighterId 角色 id。
     * @param back 成功回调。带附加参数时为 <code>back(fighter, customBackParam)</code>，否则为 <code>back(fighter)</code>。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @param customBackParam 附加参数。可省略。
     * @example
     * <listing version="3.0">
     * GameLoader.loadFighter(id, function (f:FighterMain):void {});
     * </listing>
     */
    public static function loadFighter(fighterId:String, back:Function, fail:Function = null, progress:Function = null,
                                       customBackParam:Object                                                  = null
    ):void {
        var result:FighterMain = createCacheFighter(fighterId);

        if (result) {
            if (back != null) {
                if (customBackParam) {
                    back(result, customBackParam);
                }
                else {
                    back(result);
                }
            }
            return;
        }

        loadAndCacheFighter(fighterId, loadComplete, fail, progress);

        function loadComplete():void {
            result = createCacheFighter(fighterId);

            if (back != null) {
                if (customBackParam) {
                    back(result, customBackParam);
                }
                else {
                    back(result);
                }
            }
        }

    }

    /**
     * 用缓存新建一个角色。
     *
     * @param fighterId 角色 id。
     * @return 新角色；没有缓存时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var f:FighterMain = GameLoader.createCacheFighter(id);
     * </listing>
     */
    public static function createCacheFighter(fighterId:String):FighterMain {
        var fcv:FighterCacheVO = _fighterCache[fighterId];
        if (!fcv) {
            return null;
        }

        var mainMc:MovieClip;
        if (fcv.MainClass) {
            mainMc = new fcv.MainClass();
        }
        else {
            mainMc = fcv.loader.content as MovieClip;
        }

        var fighter:FighterMain = new FighterMain(mainMc);
        fighter.data            = fcv.fighterData;

        return fighter;
    }

    /**
     * 加载援助 SWF 并在回调里给出实例。不缓存。
     *
     * @param fighterId 援助 id。
     * @param back 成功回调，参数是 <code>Assister</code>。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @param customBackParam 附加参数。有值时作为回调的第二个参数。
     * @example
     * <listing version="3.0">
     * GameLoader.loadAssister(id, function (a:Assister):void {});
     * </listing>
     */
    public static function loadAssister(fighterId:String, back:Function, fail:Function = null, progress:Function = null,
                                        customBackParam:Object                                                  = null
    ):void {
        var fv:FighterVO = AssisterModel.I.getAssister(fighterId, true);
        if (!fv) {
            TraceLang('game_loader.assister_id_error', {fighterId: fighterId});
            if (fail != null) {
                fail(GetLang('loading.assister_id_error'));
            }
            return;
        }

        loadSWF(fv.fileUrl, loadComplete, fail, progress);

        function loadComplete(loader:Loader):void {
            var fighter:Assister = new Assister(loader.content as MovieClip);
            fighter.data         = fv;
            if (back != null) {
                if (customBackParam) {
                    back(fighter, customBackParam);
                }
                else {
                    back(fighter);
                }
                back = null;
            }
        }

    }

    /**
     * 加载地图 SWF 并在回调里给出实例。不缓存。
     *
     * @param mapId 地图 id。
     * @param back 成功回调，参数是 <code>MapMain</code>。
     * @param fail 失败回调。可省略。
     * @param progress 进度回调。可省略。
     * @param customBackParam 附加参数。有值时作为回调的第二个参数。
     * @example
     * <listing version="3.0">
     * GameLoader.loadMap(id, function (map:MapMain):void {});
     * </listing>
     */
    public static function loadMap(mapId:String, back:Function, fail:Function = null, progress:Function = null,
                                   customBackParam:Object                                              = null
    ):void {
        var mv:MapVO = MapModel.I.getMap(mapId);
        if (!mv) {
            TraceLang('game_loader.map_id_error', {mapId: mapId});
            if (fail != null) {
                fail(GetLang('loading.map_id_error'));
            }
            return;
        }

        loadSWF(mv.fileUrl, loadComplete, fail, progress);

        function loadComplete(loader:Loader):void {
            var map:MapMain = new MapMain(loader.content as Sprite);
            map.data        = mv;
            if (back != null) {
                if (customBackParam) {
                    back(map, customBackParam);
                }
                else {
                    back(map);
                }
                back = null;
            }
        }
    }

    /**
     * 清空角色缓存并卸载已记下的 SWF。
     *
     * <p>卸载失败时改调 <code>unload</code>。进行中的加载不会取消。</p>
     *
     * @example
     * <listing version="3.0">
     * GameLoader.dispose();
     * </listing>
     */
    public static function dispose():void {

        for (var i:String in _fighterCache) {
            var cv:FighterCacheVO = _fighterCache[i];
            cv.fighterData        = null;
            cv.MainClass          = null;
            cv.loader             = null;
        }

        while (_loadedSwfCache.length) {
            var l:Loader = _loadedSwfCache.shift();
            try {
                l.unloadAndStop(true);
            }
            catch (e:Error) {
                TraceLang('game_loader.unload_cache_error', {error: e});
                l.unload();
            }
        }

        _fighterCache = {};
    }

    /**
     * 加载一份 SWF 并记入卸载列表。
     *
     * @param url 地址。
     * @param back 成功回调，参数是 <code>Loader</code>。调用一次后不再回调。
     * @param fail 失败回调，参数是一句加载文案。可省略。
     * @param progress 进度回调。可省略。
     * @example
     * <listing version="3.0">
     * GameLoader.loadSWF(url, function (loader:Loader):void {});
     * </listing>
     */
    public static function loadSWF(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        AssetManager.I.loadSWF(url, loadComplete, loadIOError, progress);

        function loadComplete(l:Loader):void {
            _loadedSwfCache.push(l);
            if (back != null) {
                back(l);
                back = null;
            }
        }

        function loadIOError():void {
            LogLang(GameLogger.DEBUG, 'load', 'game_loader.load_swf_error', {url: url});
            if (fail != null) {
                fail(GetLang('loading.load_swf_error'));
            }
        }

    }


}
}

import flash.display.Loader;

import net.play5d.game.bvn.data.vos.FighterVO;

/**
 * 一份已加载角色的 Loader、主类和数据。
 *
 * @private
 */
internal class FighterCacheVO {
    /** @private */
    public var loader:Loader;
    /** @private */
    public var MainClass:Class;
    /** @private */
    public var fighterData:FighterVO;
}
