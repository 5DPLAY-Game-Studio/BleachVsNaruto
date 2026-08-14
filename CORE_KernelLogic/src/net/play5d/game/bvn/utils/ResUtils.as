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
import flash.utils.Dictionary;
import flash.utils.describeType;

import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.interfaces.ISwfLib;

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

//		[Embed(source="/../fonts/simhei.ttf", fontName="黑体", mimeType="application/x-font")]
//		private var GameFont:Class;
    private var _initing:Boolean;

    public function initialize(back:Function = null, error:Function = null):void {

        if (_initing) {
            throw new Error(GetLang('debug.error.data.res_utils.init_in_progress'));
        }

        if (swfLib == null) {
            throw new Error(GetLang('debug.error.data.res_utils.swf_lib_not_init'));
        }

        if (_inited) {
            if (back != null) {
                back();
            }
            return;
        }

//			try {
//				Security.allowDomain("*");
//			}catch (e) {
//				trace(e);
//			};

        _inited  = true;
        _initing = true;

        _swfPool ||= new Dictionary();

        _initBack  = back;
        _initError = error;

        var xml:XML  = describeType(swfLib);
        var o:Object = {};

        for each(var j:XML in xml.accessor) {
            var k:String  = j.@name;
            var cls:Class = swfLib[k];

            var swf:EmbedSwf = new EmbedSwf(cls);
            swf.ready      = swfReadyBack;
            swf.error      = swfErrorBack;
            _swfPool[cls]  = swf;

        }

    }

    public function addSwf(c:Class):void {
        _swfPool ||= new Dictionary();

        var swf:EmbedSwf = new EmbedSwf(c);
        swf.ready      = swfReadyBack;
        swf.error      = swfErrorBack;
        _swfPool[c]    = swf;
    }

    public function createDisplayObject(embedSwf:Class, itemName:String):* {
        var cls:Class = getItemClass(embedSwf, itemName);
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

    public function createBitmapData(embedSwf:Class, itemName:String, width:int, height:int):BitmapData {
        var cls:Class = getItemClass(embedSwf, itemName);
        if (!cls) {
            return null;
        }
        var bd:BitmapData = new cls(width, height);
        return bd;
    }

    public function getItemClass(embedSwf:Class, itemName:String):Class {

        if (!_swfPool) {
            throw new Error(GetLang('debug.error.data.res_utils.not_initialized'));
        }

        var swf:EmbedSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getClass(itemName);
    }

    public function getItemProperty(embedSwf:Class, name:String):* {
        if (!_swfPool) {
            throw new Error(GetLang('debug.error.data.res_utils.not_initialized'));
        }

        var swf:EmbedSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getProperty(name);
    }

    public function callSwfFunction(embedSwf:Class, func:String, params:Array = null):* {
        if (!_swfPool) {
            throw new Error(GetLang('debug.error.data.res_utils.not_initialized'));
        }

        var swf:EmbedSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.call(func, params);
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
