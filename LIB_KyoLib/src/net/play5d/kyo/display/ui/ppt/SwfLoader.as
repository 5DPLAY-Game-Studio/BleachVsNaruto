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

package net.play5d.kyo.display.ui.ppt {
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import mx.rpc.events.FaultEvent;

public class SwfLoader extends Sprite {
    public function SwfLoader(
            url:String = null, size:Point = null, back:Function = null, fail:Function = null,
            process:Function                                                          = null
    ) {
        super();

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
        _loader.addEventListener(FaultEvent.FAULT, fatalErrorHandler);
        addChild(_loader);

        _size           = size;
        this.scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        if (url != null) {
            loadSwf(url, back, fail, process);
        }
    }
    private var _size:Point;
    private var _swfWidth:Number  = 0;
    private var _swfHeight:Number = 0;
    private var _loader:Loader;
    private var _loadBack:Function;
    private var _failBack:Function;
    private var _process:Function;

    public function loadSwf(url:String, back:Function = null, fail:Function = null, process:Function = null):void {
        _loadBack = back;
        _failBack = fail;
        _process  = process;

        _loader.load(new URLRequest(url));
    }

    public function unload():void {
        if (_loader) {
            _loader.unloadAndStop(true);
        }
    }

    private function IOErrorHandler(event:IOErrorEvent):void {
        trace('SWFLoader:IOErrorHandler : ' + event);
        if (_failBack != null) {
            _failBack();
            _failBack = null;
        }
    }

    private function fatalErrorHandler(event:FaultEvent):void {
        trace('SWFLoader:fatalErrorHandler : ' + event);
        if (_failBack != null) {
            _failBack();
            _failBack = null;
        }
    }

    private function onProcess(e:ProgressEvent):void {
        if (_process != null) {
            var per:Number = e.bytesLoaded / e.bytesTotal;
            _process(this, per);
        }
    }

    private function loadSwfComplete(e:Event):void {
        var loaderinfo:LoaderInfo = (
                e.currentTarget as LoaderInfo
        );
        _swfWidth                 = loaderinfo.width;
        _swfHeight                = loaderinfo.height;

        if (_size) {
            _loader.scaleX = _size.x / _swfWidth;
            _loader.scaleY = _size.y / _swfHeight;
        }

        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
    }

}
}
