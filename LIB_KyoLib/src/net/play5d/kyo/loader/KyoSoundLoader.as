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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class KyoSoundLoader {
    public function KyoSoundLoader() {
    }

    private var _urls:Array;
    private var _curUrl:String;
    private var _soundObj:Object = {};
    private var _loadBack:Function;
    private var _loadProcess:Function;
    private var _loadLength:int;

    public function unload():void {
        if (_soundObj) {
            for each(var s:Sound in _soundObj) {
                s.close();
            }
            _soundObj = {};
        }
    }

    public function loadSounds(urls:Array, back:Function = null, process:Function = null):void {
        _loadBack    = back;
        _loadProcess = process;
        _urls        = urls.concat();
        _loadLength  = urls.length;

        loadNext();
    }

    /**
     * 获取SOUND
     * @param pathOrname 完整路径（包含后缀名）或文件名字（不含后缀名）
     */
    public function getSound(pathOrname:String):Sound {
        if (_soundObj[pathOrname]) {
            return _soundObj[pathOrname];
        }

        for (var i:String in _soundObj) {
            var name:String = i.substr(i.lastIndexOf('/') + 1);
            name            = name.substr(0, name.lastIndexOf('.'));
            if (name == pathOrname) {
                return _soundObj[i];
            }
        }

        return null;
    }

    public function addSound(url:String, sound:Sound):void {
        _soundObj[url] = sound;
    }

    public function loadPath(path:String, listXML:String, back:Function = null):void {
        var l:URLLoader = new URLLoader(new URLRequest(path + '/' + listXML));
        l.addEventListener(Event.COMPLETE, function (e:Event):void {
            var xml:XML    = new XML(l.data);
            var urls:Array = [];
            for each(var i:Object in xml.children()) {
                urls.push(path + '/' + i.toString());
            }

            loadSounds(urls, back);

        });
    }

    private function loadNext():void {
        var url:String = _urls.shift();
        _curUrl        = url;

        var sound:Sound = new Sound(new URLRequest(url));
        sound.addEventListener(Event.COMPLETE, loadCom);
        sound.addEventListener(ProgressEvent.PROGRESS, loadProcess);
        sound.addEventListener(IOErrorEvent.IO_ERROR, loadErr);
    }

    private function loadFin():void {
        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
    }

    private function loadProcess(e:ProgressEvent):void {
        if (_loadProcess != null) {
            var v:Number   = e.bytesLoaded / e.bytesTotal;
            var cur:Number = _loadLength - _urls.length - 1 + v;
            var p:Number   = cur / _loadLength;
            _loadProcess(p);
        }
    }

    private function loadCom(e:Event):void {
        var snd:Sound = e.currentTarget as Sound;
        snd.removeEventListener(Event.COMPLETE, loadCom);
        snd.removeEventListener(IOErrorEvent.IO_ERROR, loadErr);
        snd.removeEventListener(ProgressEvent.PROGRESS, loadProcess);

        _soundObj[_curUrl] = snd;

        if (_urls.length < 1) {
            loadFin();
        }
        else {
            loadNext();
        }

    }

    private function loadErr(e:IOErrorEvent):void {
        var snd:Sound = e.currentTarget as Sound;
        snd.removeEventListener(Event.COMPLETE, loadCom);
        snd.removeEventListener(IOErrorEvent.IO_ERROR, loadErr);
        snd.removeEventListener(ProgressEvent.PROGRESS, loadProcess);

        trace('KyoSoundLoader.loadErr :: 加载声音失败 : ' + snd.url);

        if (_urls.length < 1) {
            loadFin();
        }
        else {
            loadNext();
        }
    }


}
}
