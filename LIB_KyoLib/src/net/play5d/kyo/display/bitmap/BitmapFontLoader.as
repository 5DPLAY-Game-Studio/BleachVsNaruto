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

package net.play5d.kyo.display.bitmap {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;

import net.play5d.kyo.loader.BitmapLoader;
import net.play5d.kyo.loader.KyoURLoader;

public class BitmapFontLoader {
    public function BitmapFontLoader() {
    }

    private var _urls:Array;
    private var _fontObj:Object = {};
    private var _loadAmount:int;
    private var _loadBack:Function;
    private var _loadProcess:Function;

    public function clear():void {
        _fontObj = {};
    }

    public function loadFonts(urls:Array, back:Function = null, process:Function = null):void {
        _loadBack    = back;
        _loadProcess = process;

        _urls       = urls;
        _loadAmount = urls.length;

        loadNext();
    }

    public function loadFont(url:String, fontXML:XML, back:Function = null, fail:Function = null):void {
        var bpurl:String  = fontXML.pages.page.@file;
        var floder:String = url.substr(0, url.lastIndexOf('/') + 1);
        var bpUrl:String  = floder + bpurl;
        loadBitmapData(bpUrl, fontXML, back, fail);
    }

    public function addFont(xml:XML, bitmap:BitmapData):void {
        var fontid:String = xml.info.@face;
        _fontObj[fontid]  = new BitmapFont(xml, bitmap);
    }

    public function getFont(id:String):BitmapFont {
        return _fontObj[id];
    }

    private function loadComplete():void {
        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
        _loadProcess = null;
    }

    private function loadNext():void {

        if (_loadProcess != null) {
            var cur:int = _loadAmount - _urls.length;
            _loadProcess(cur / _loadAmount);
        }

        if (_urls.length < 1) {
            loadComplete();
            return;
        }

        var url:String = _urls.shift();
        KyoURLoader.load(url, loadXMLFin, loadXMLFail);

        function loadXMLFin(v:String):void {
            var xml:XML       = new XML(v);
            var bpurl:String  = xml.pages.page.@file;
            var floder:String = url.substr(0, url.lastIndexOf('/') + 1);
            var bpUrl:String  = floder + bpurl;
            loadBitmapData(bpUrl, xml, loadNext, loadNext);
        }

        function loadXMLFail():void {
            trace('BitmapFontLoader.loadXMLFail::' + url);
            loadNext();
        }
    }


    private function loadBitmapData(bpurl:String, xml:XML, back:Function = null, fail:Function = null):void {

        var fontid:String = xml.info.@face;

        var loader:BitmapLoader = new BitmapLoader();
        loader.load(bpurl, loadBpComplete, loadBpFail);

        function loadBpComplete(b:Bitmap):void {
            _fontObj[fontid] = new BitmapFont(xml, b.bitmapData);
            if (back != null) {
                back();
            }
        }

        function loadBpFail(e:Event):void {
            trace('BitmapFontLoader.loadBpFail::' + bpurl);
            if (fail != null) {
                fail();
            }
        }
    }

}
}
