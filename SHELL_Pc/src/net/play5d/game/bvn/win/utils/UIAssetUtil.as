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

package net.play5d.game.bvn.win.utils {
import flash.display.BitmapData;
import flash.utils.Dictionary;
import flash.utils.describeType;

public class UIAssetUtil {

    private static var _i:UIAssetUtil;

    public static function get I():UIAssetUtil {
        _i ||= new UIAssetUtil();
        return _i;
    }

    public function UIAssetUtil() {
    }
    [Embed(source='/../../shared/lib/swf/win_ui.swf')]
    public var win_ui:Class;
    private var _swfPool:Dictionary;
    private var _initBack:Function;
    private var _inited:Boolean;
    private var _initing:Boolean;

    public function initalize(back:Function = null):void {

        if (_initing) {
            throw new Error('正在初始化过程中，不能再次初始化！');
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

        _swfPool = new Dictionary();

        _initBack = back;

        var xml:XML  = describeType(this);
        var o:Object = {};

        for each(var j:XML in xml.variable) {
            var k:String  = j.@name;
            var cls:Class = this[k];

            var swf:InsSwf = new InsSwf(cls);
            swf.ready      = swfReadyBack;
            _swfPool[cls]  = swf;

        }

    }

    public function createDisplayObject(itemName:String):* {
        var cls:Class = getItemClass(itemName);
        if (cls) {
            return new cls();
        }
    }

    public function createBitmapData(itemName:String, width:int, height:int):BitmapData {
        var cls:Class = getItemClass(itemName);
        if (!cls) {
            return null;
        }
        var bd:BitmapData = new cls(width, height);
        return bd;
    }

    public function getItemClass(itemName:String):Class {

        if (!_swfPool) {
            throw new Error('未进行初始化！');
        }

//			return null;

        var swf:InsSwf = _swfPool[win_ui];
        if (!swf) {
            throw new Error('swf is undefined!');
        }
        return swf.getClass(itemName);
    }

    private function swfReadyBack(target:InsSwf):void {
        for each(var i:InsSwf in _swfPool) {
            if (!i.isReady) {
                return;
            }
        }
        finish();
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
    private var _swf:*;
    private var _domain:ApplicationDomain;

    public function getClass(name:String):Class {
        return _domain.getDefinition(name) as Class;
    }

    private function loadComplete(e:Event):void {
        var l:LoaderInfo = e.currentTarget as LoaderInfo;
        _domain          = l.applicationDomain;

        isReady = true;

        if (ready != null) {
            ready(this);
            ready = null;
        }

    }

}
