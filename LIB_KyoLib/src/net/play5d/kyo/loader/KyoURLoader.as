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
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

public class KyoURLoader {
    public static const TYPE_UNICODE:String            = 'Unicode';
    public static const TYPE_UNICODE_BIG_ENDIAN:String = 'Unicode big endian';
    public static const TYPE_UTF8:String               = 'UTF-8';
    public static const TYPE_ANSI:String               = 'ANSI';
    public static var showDebug:Boolean                = true;
    public static var errorStr:String;

    /**
     * LOAD数据
     * @param url 网址
     * @param back 成功后调用，函数需要1个参数：DATA：String
     * @param failBack 失败后调用,0个参数
     */
    public static function load(url:String, back:Function, failBack:Function = null, param:Object = null):void {
        errorStr = null;

        var loader:URLLoader = new URLLoader();
        if (param) {
            for (var i:String in param) {
                loader[i] = param[i];
            }
        }
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError2);
        loader.load(new URLRequest(url));

        function onComplete(e:Event):void {
            if (back != null) {
                back(loader.data);
            }
            loader = null;
        }

        function onError(e:IOErrorEvent):void {
            errorStr = e.toString();
            if (failBack != null) {
                failBack();
            }
            loader = null;
            if (showDebug) {
                trace(e);
            }
        }

        function onError2(e:SecurityErrorEvent):void {
            errorStr = e.toString();
            if (failBack != null) {
                failBack();
            }
            loader = null;
        }
    }

    /**
     * 发送POST请求
     * @param url 网址
     * @param data 发送参数 URLVariables 或 Object
     * @param back 成功后调用，函数需要1个参数：DATA：String
     * @param failBack 失败后调用,0个参数
     */
    public static function post(url:String, data:Object, back:Function = null, failBack:Function = null):void {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);

        var uq:URLRequest = new URLRequest(url);
        uq.method         = URLRequestMethod.POST;
        if (data is URLVariables) {
            uq.data = data;
        }
        else {
            var uv:URLVariables = new URLVariables();
            for (var i:String in data) {
                uv[i] = data[i];
            }
            uq.data = uv;
        }
        loader.load(uq);


        function onComplete(e:Event):void {
            if (back != null) {
                back(loader.data);
            }
            loader = null;
        }

        function onError(e:IOErrorEvent):void {
            if (failBack != null) {
                failBack();
            }
            loader = null;
            if (showDebug) {
                trace(e);
            }
        }
    }

    public static function getFileType(fileData:ByteArray):String {
        var b0:int = fileData.readUnsignedByte();
        var b1:int = fileData.readUnsignedByte();

        fileData.position = 0;

        if (b0 == 0xFF && b1 == 0xFE) {
            return TYPE_UNICODE;
        }
        if (b0 == 0xFE && b1 == 0xFF) {
            return TYPE_UNICODE_BIG_ENDIAN;
        }
        if (b0 == 0xEF && b1 == 0xBB) {
            return TYPE_UTF8;
        }
        return TYPE_ANSI;
    }

    public function KyoURLoader() {
    }

}
}
