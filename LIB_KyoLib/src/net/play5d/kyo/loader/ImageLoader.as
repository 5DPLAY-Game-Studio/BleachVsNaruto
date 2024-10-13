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

package net.play5d.kyo.loader {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Point;
import flash.net.URLRequest;

public class ImageLoader extends Loader {
    public static var traceError:Boolean = true;

    public function ImageLoader(url:String = null, size:Point = null, back:Function = null, fail:Function = null) {
        super();
        _size = size;
        if (url) {
            loadImage(url, back, fail);
        }
    }
    /**
     * 忽略错误
     */
    public var mergeError:Boolean        = true;
    public var loadFail:Boolean;
    private var _size:Point;
    private var _back:Function;
    private var _fail:Function;

    private var _url:String;

    public function get url():String {
        return _url;
    }

    private var _smooth:Boolean;

    public function get smooth():Boolean {
        return _smooth;
    }

    public function set smooth(v:Boolean):void {
        _smooth = v;
        if (content) {
            var bp:Bitmap = content as Bitmap;
            if (bp) {
                bp.smoothing = v;
            }
        }
    }

    public function loadImage(url:String, back:Function = null, fail:Function = null):void {
        unloadAndDispose();
        try {
            this['unloadAndStop'](true);
        }
        catch (e:Error) {
        }

        _url     = url;
        loadFail = false;
        _back    = back;
        _fail    = fail;

        contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

        load(new URLRequest(url));
    }

    public function unloadAndDispose():void {
        if (content) {
            var bp:Bitmap = content as Bitmap;
            unload();
            if (bp) {
                bp.bitmapData.dispose();
            }
        }
    }

    public function reload():void {
        loadImage(_url);
    }

    private function removeListener():void {
        contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
    }

    private function onComplete(e:Event):void {
        if (_size) {
            if (_size.x == 0) {
                height = _size.y;
                scaleX = scaleY;
            }
            else if (_size.y == 0) {
                width  = _size.x;
                scaleY = scaleX;
            }
            else {
                width  = _size.x;
                height = _size.y;
            }
        }

        smooth = _smooth;

        dispatchEvent(e);
        if (_back != null) {
            _back(this);
            _back = null;
        }
        removeListener();
    }

    private function onIOError(e:IOErrorEvent):void {
        if (traceError) {
            trace('load error :', _url);
        }
        loadFail = true;
        if (!mergeError) {
            dispatchEvent(e);
        }
        if (_fail != null) {
            _fail(this);
            _fail = null;
        }
        removeListener();
    }
}
}
