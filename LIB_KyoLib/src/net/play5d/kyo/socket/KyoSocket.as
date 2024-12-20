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

package net.play5d.kyo.socket {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

public class KyoSocket {
    public function KyoSocket() {
    }

    /**
     * 字符串编码格式
     */
    public var charset:String     = 'UTF-8';
    /**
     * 断线后自动重新连接服务器
     */
    public var autoConnect:Boolean;
    /**
     * 自动重连时间间隔（秒）
     */
    public var autoConnectGap:int = 1;
    public var on_error:Function;
    public var on_connect:Function;
    public var on_close:Function;
    public var on_data:Function;
    private var _socket:Socket;
    private var _host:String, _port:int;

    public function get connected():Boolean {
        return _socket.connected;
    }

    public function connect(host:String = 'localhost', port:int = 0):void {
        _host = host;
        _port = port;

        _socket = new Socket(host, port);
        _socket.addEventListener(Event.CLOSE, closeHandler);
        _socket.addEventListener(Event.CONNECT, connectHandler);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ercurityErrorHandler);
        _socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
    }

    public function sendMsg(msg:*, length:int = 32):void {
        if (!connected) {
            return;
        }
        if (msg is int) {
            _socket.writeInt(msg);
            _socket.flush();
            return;
        }
        if (msg is String) {
            var b:ByteArray = new ByteArray();
            b.writeMultiByte(msg, charset);
            b.length = length;
            sendByteArray(b);
            _socket.flush();
            return;
        }
    }

    public function sendByteArray(b:ByteArray):void {
        if (!_socket.connected) {
            return;
        }
        _socket.writeBytes(b);
        _socket.flush();
    }

    public function sendObject(o:Object):void {
        if (!_socket.connected) {
            return;
        }
        _socket.writeObject(o);
        _socket.flush();
    }

    public function reConnect():void {
        if (_socket.connected) {
            return;
        }
        _socket.connect(_host, _port);
    }

    private function onConnectClose():void {
        if (autoConnect) {
            setTimeout(reConnect, autoConnectGap * 1000);
        }
        if (on_close != null) {
            on_close();
        }
    }

    private function closeHandler(e:Event):void {
        trace('连接中断');
        onConnectClose();
    }

    private function connectHandler(e:Event):void {
        trace('连接成功');
        if (on_connect != null) {
            on_connect();
        }
    }

    private function ioErrorHandler(e:IOErrorEvent):void {
        trace('IO错误');
        if (on_error != null) {
            on_error('IO错误');
        }
        onConnectClose();
    }

    private function ercurityErrorHandler(e:SecurityErrorEvent):void {
        trace('安全性错误');
        if (on_error != null) {
            on_error('安全性错误');
        }
        onConnectClose();
    }

    private function dataHandler(e:ProgressEvent):void {
        trace('接收到数据');
        if (on_data != null) {
            var buffer:ByteArray = new ByteArray();
            e.currentTarget.readBytes(buffer, 0, e.currentTarget.bytesAvailable);
            on_data(buffer);
        }
    }

}
}
