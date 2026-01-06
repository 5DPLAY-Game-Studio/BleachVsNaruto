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
    include '../../../../../../include/_INCLUDE_.as';

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

    public function ResUtils() {
    }
    private var _swfPool:Dictionary;
    private var _initBack:Function;
    private var _initError:Function;
    private var _inited:Boolean;

//		[Embed(source="/../fonts/simhei.ttf", fontName="黑体", mimeType="application/x-font")]
//		private var GameFont:Class;
    private var _initing:Boolean;

    public function initalize(back:Function = null, error:Function = null):void {

        if (_initing) {
            throw new Error('正在初始化过程中，不能再次初始化！');
        }

        if (swfLib == null) {
            throw new Error('未初始化SwfLib !!');
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

            var swf:InsSwf = new InsSwf(cls);
            swf.ready      = swfReadyBack;
            swf.error      = swfErrorBack;
            _swfPool[cls]  = swf;

        }

    }

    public function addSwf(c:Class):void {
        _swfPool ||= new Dictionary();

        var swf:InsSwf = new InsSwf(c);
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
            throw new Error('未进行初始化！');
        }

        var swf:InsSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getClass(itemName);
    }

    public function getItemProperty(embedSwf:Class, name:String):* {
        if (!_swfPool) {
            throw new Error('未进行初始化！');
        }

        var swf:InsSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getProperty(name);
    }

    public function callSwfFunction(embedSwf:Class, func:String, params:Array = null):* {
        if (!_swfPool) {
            throw new Error('未进行初始化！');
        }

        var swf:InsSwf = _swfPool[embedSwf];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.call(func, params);
    }

    private function swfReadyBack(target:InsSwf):void {
        for each(var i:InsSwf in _swfPool) {
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

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

internal class InsSwf {

    public function InsSwf(swfClass:Class) {
        _swf = new swfClass();

        var bytes:ByteArray = _swf.movieClipData;

        if (!bytes) {
            error('未发现swf的movieClipData!');
            throw new Error('未发现swf的movieClipData!');
        }

        var loader:Loader = new Loader();
//		if(!loader){
//			throw new Error('未发现loader!');
//		}
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);

        var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        lc.allowCodeImport   = true;

        loader.loadBytes(bytes, lc);
    }
    public var isReady:Boolean;
    public var ready:Function;
    public var error:Function;
    private var _swf:*;
    private var _domain:ApplicationDomain;
    private var _content:DisplayObject;

    public function getClass(name:String):Class {
        return _domain.getDefinition(name) as Class;
    }

    public function getProperty(name:String):* {
        return _content[name];
    }

    public function call(func:String, params:Array = null):* {
        if (!_content) {
            trace('swf is null !');
            return null;
        }

        try {
            var fn:Function = _content[func];
            return fn.apply(null, params);
        }
        catch (e:Error) {
            trace(e);
            throw new Error('swf.' + func + ' call failed ! ');
        }

    }

    private function loadComplete(e:Event):void {
        var l:LoaderInfo = e.currentTarget as LoaderInfo;
        _domain          = l.applicationDomain;
        _content         = l.content;

        isReady = true;

        if (ready != null) {
            ready(this);
            ready = null;
        }

    }

}
