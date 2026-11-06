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

package net.play5d.game.bvn.utils {
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.describeType;

import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.interfaces.ISwfLib;
import net.play5d.kyo.loader.KyoLoaderLite;

public class ResUtils {

    public static var SETTING:String         = '$setting$MC_stgSetUI';
    public static var CONGRATULATIONS:String = '$common$MC_congratulations';
    public static var WINNER:String          = '$loading$MC_stageWinner';
    public static var TITLE:String           = '$title$MC_stgTitle';
    public static var GAME_OVER:String       = '$game_over$MC_stgGameOver';
    public static var SELECT:String          = '$select$MC_stgSelect';
    public static var BIG_MAP:String         = '$big_map$MC_bigMap';
    public static var swfLib:ISwfLib;
    private static var _i:ResUtils;

    public static function get I():ResUtils {
        _i ||= new ResUtils();
        return _i;
    }

    private var _swfPool:Dictionary;
    private var _initBack:Function;
    private var _initError:Function;
    private var _inited:Boolean;
    private var _initing:Boolean;

    public function initialize(back:Function = null, error:Function = null):void {

        if (_initing) {
            throw new Error(GetLang('log.error.load.res_utils.init_in_progress'));
        }

        if (swfLib == null) {
            throw new Error(GetLang('log.error.load.res_utils.swf_lib_not_init'));
        }

        if (_inited) {
            if (back != null) {
                back();
            }
            return;
        }

        _inited  = true;
        _initing = true;

        _swfPool ||= new Dictionary();

        _initBack  = back;
        _initError = error;

        var xml:XML = describeType(swfLib);

        for each(var j:XML in xml.accessor) {
            var value:* = swfLib[String(j.@name)];
            if (value is String && value) {
                openSwf(value);
            }
        }

    }

    public function addSwf(url:String):void {
        _swfPool ||= new Dictionary();
        openSwf(url);
    }

    public function createDisplayObject(swf:String, itemName:String):* {
        var cls:Class = getItemClass(swf, itemName);
        if (cls) {
            var d:* = new cls();
            if (d is Sprite) {
                var mc:Sprite         = d as Sprite;
                var st:SoundTransform = mc.soundTransform;
                st.volume             = GameData.I.config.soundVolume;
                mc.soundTransform     = st;
                return mc;
            }
            return d;
        }
    }

    public function createBitmapData(swf:String, itemName:String, width:int, height:int):BitmapData {
        var cls:Class = getItemClass(swf, itemName);
        if (!cls) {
            return null;
        }
        var bd:BitmapData = new cls(width, height);
        return bd;
    }

    public function getItemClass(swf:String, itemName:String):Class {
        return find(swf).getClass(itemName);
    }

    public function getItemProperty(swf:String, name:String):* {
        return find(swf).getProperty(name);
    }

    public function callSwfFunction(swf:String, func:String, params:Array = null):* {
        return find(swf).call(func, params);
    }

    /** @private */
    private function openSwf(url:String):void {
        var swf:EmbedSwf = new EmbedSwf();
        swf.ready        = swfReadyBack;
        swf.error        = swfErrorBack;
        _swfPool[url]    = swf;

        KyoLoaderLite.loadBytes('assets/' + url, function (bytes:ByteArray):void {
            swf.open(bytes);
        }, function ():void {
            swfErrorBack(url);
        });
    }

    /** @private */
    private function find(swf:String):EmbedSwf {
        if (!_swfPool) {
            throw new Error(GetLang('log.error.load.res_utils.not_initialized'));
        }

        var loaded:EmbedSwf = _swfPool[swf];
        if (!loaded) {
            throw new Error('swf is undefined!');
        }

        return loaded;
    }

    private function swfReadyBack(target:EmbedSwf):void {
        for each(var i:EmbedSwf in _swfPool) {
            if (!i.isReady) {
                return;
            }
        }
        finish();
    }

    private function swfErrorBack(msg:String):void {
        if (_initError != null) {
            _initError();
        }
    }

    private function finish():void {

        _initing = false;

        if (_initBack != null) {
            _initBack();
            _initBack = null;
        }
    }

}
}
