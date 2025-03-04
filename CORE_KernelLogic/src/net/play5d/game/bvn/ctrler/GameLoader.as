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
import net.play5d.game.bvn.data.MapVO;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.map.MapMain;

public class GameLoader {
    include '../../../../../../include/_INCLUDE_.as';

    // 角色缓存{ String: <FighterCacheVO> }
    private static var _fighterCache:Object = {};

    // swf缓存
    private static var _loadedSwfCache:Vector.<Loader> = new Vector.<Loader>();

    public static function loadAndCacheFighter(fighterId:String, back:Function, fail:Function = null,
                                               process:Function                               = null
    ):void {
        if (_fighterCache[fighterId]) {
            if (back != null) {
                back();
            }
            return;
        }


        var fv:FighterVO = FighterModel.I.getFighter(fighterId, true);
        if (!fv) {
            TraceLang('debug.trace.data.game_loader.fighter_id_error', fighterId);
            if (fail != null) {
                fail(GetLang('txt.game_loader.fighter_id_error'));
            }
            return;
        }

        loadSWF(fv.fileUrl, loadComplete, fail, process);

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
                TraceLang('debug.trace.data.game_loader.fighter_load_error', e);
            }

            if (back != null) {
                back();
            }
        }
    }

    public static function loadFighter(fighterId:String, back:Function, fail:Function = null, process:Function = null,
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

        loadAndCacheFighter(fighterId, loadComplete, fail, process);

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

    public static function loadAssister(fighterId:String, back:Function, fail:Function = null, process:Function = null,
                                        customBackParam:Object                                                  = null
    ):void {
        var fv:FighterVO = AssisterModel.I.getAssister(fighterId, true);
        if (!fv) {
            TraceLang('debug.trace.data.game_loader.assister_id_error', fighterId);
            if (fail != null) {
                fail(GetLang('txt.game_loader.assister_id_error'));
            }
            return;
        }

        loadSWF(fv.fileUrl, loadComplete, fail, process);

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

    public static function loadMap(mapId:String, back:Function, fail:Function = null, process:Function = null,
                                   customBackParam:Object                                              = null
    ):void {
        var mv:MapVO = MapModel.I.getMap(mapId);
        if (!mv) {
            TraceLang('debug.trace.data.game_loader.map_id_error', mapId);
            if (fail != null) {
                fail(GetLang('txt.game_loader.map_id_error'));
            }
            return;
        }

        loadSWF(mv.fileUrl, loadComplete, fail, process);

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
                TraceLang('debug.trace.data.game_loader.unload_cache_error', e);
                l.unload();
            }
        }

        _fighterCache = {};
    }

    public static function loadSWF(url:String, back:Function, fail:Function = null, process:Function = null):void {
        AssetManager.I.loadSWF(url, loadComplete, loadIOError, process);

        function loadComplete(l:Loader):void {
            _loadedSwfCache.push(l);
            if (back != null) {
                back(l);
                back = null;
            }
        }

        function loadIOError():void {
            Debugger.log(GetLang('debug.log.data.game_loader.load_swf_error'), url);
            if (fail != null) {
                fail(GetLang('txt.game_loader.load_swf_error'));
            }
        }

    }

    public function GameLoader() {
    }


}
}

import flash.display.Loader;

import net.play5d.game.bvn.data.vos.FighterVO;

internal class FighterCacheVO {
    public var loader:Loader;
    public var MainClass:Class;
    public var fighterData:FighterVO;
}
