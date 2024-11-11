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
import flash.net.URLRequest;

public class BitmapLoader {
    public function BitmapLoader() {
    }

    public var bitmap:Bitmap;
    public var url:String;

    public function load(url:String, back:Function = null, fail:Function = null):void {
        this.url = url;

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadFail);
        loader.load(new URLRequest(url));

        function loadComplete(e:Event):void {
            bitmap = loader.content as Bitmap;

            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadFail);
            loader.unload();
            loader = null;

            if (back != null) {
                back(bitmap);
            }
        }

        function loadFail(e:IOErrorEvent):void {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadFail);
            loader = null;
            if (fail != null) {
                fail();
            }
        }

    }

}
}
