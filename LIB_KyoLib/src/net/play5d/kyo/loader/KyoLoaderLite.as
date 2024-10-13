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
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

public class KyoLoaderLite {
    public static function load(url:String, back:Function, fail:Function, process:Function):void {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        l.load(new URLRequest(url));

        function loadComplete(e:Event):void {
            var d:DisplayObject = l.content;
            if (back != null) {
                back(d);
            }
            clear();
        }

        function ioError(e:IOErrorEvent):void {
            if (fail != null) {
                fail();
            }
            clear();
        }

        function progressHandler(e:ProgressEvent):void {
            if (process != null) {
                process(e.bytesLoaded / e.bytesTotal);
            }
        }

        function clear():void {
            if (l == null) {
                return;
            }
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            l.unloadAndStop(true);
            l = null;
        }

    }

    public static function loadLoader(url:String, back:Function, fail:Function, process:Function):void {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        l.load(new URLRequest(url));

        function loadComplete(e:Event):void {
            if (back != null) {
                back(l);
            }
            clear();
        }

        function ioError(e:IOErrorEvent):void {
            if (fail != null) {
                fail();
            }
            clear();
        }

        function progressHandler(e:ProgressEvent):void {
            if (process != null) {
                process(e.bytesLoaded / e.bytesTotal);
            }
        }

        function clear():void {
            if (l == null) {
                return;
            }
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
        }

    }

    public static function loadBytes(url:String, back:Function, fail:Function = null, progress:Function = null):void {

        var loader:URLLoader = new URLLoader();
        loader.dataFormat    = URLLoaderDataFormat.BINARY;

        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        loader.load(new URLRequest(url));

        function onComplete(e:Event):void {
            if (back != null) {
                back(loader.data as ByteArray);
            }
            loader = null;
        }

        function onError(e:*):void {
            if (fail != null) {
                fail();
            }
            loader = null;
            trace(e);
        }

        function onProgress(e:ProgressEvent):void {
            if (progress != null) {
                progress(e.bytesLoaded / e.bytesTotal);
            }
        }

    }

    /**
     * BYTEARRAY to DISPLAY_OBJECT
     * @param bytes
     * @param onComplete 1 param: Loader
     * @param onError
     * @return Loader
     */
    public static function bytesToDisplay(bytes:ByteArray, onComplete:Function = null, onError:Function = null):Loader {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        var ctx:LoaderContext = new LoaderContext();
        ctx.allowCodeImport   = true;
        loader.loadBytes(bytes, ctx);

        function onLoadComplete(e:Event):void {
            if (onComplete != null) {
                onComplete(loader);
            }
        }

        function onLoadError(e:*):void {
            if (onError != null) {
                onError();
            }
            trace(e);
        }

        return loader;
    }

    public function KyoLoaderLite() {
    }

}
}
