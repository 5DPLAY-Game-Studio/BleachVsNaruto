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

package net.play5d.game.bvn.win.sockets.udp {
import flash.events.DatagramSocketDataEvent;
import flash.net.DatagramSocket;
import flash.net.InterfaceAddress;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.data.lan.UdpPacketUtils;

/**
 * UDP协议收发消息管理器（Pc / DatagramSocket）。
 */
public class UDPSocket {
    public function UDPSocket() {
        trace('DatagramSocket.isSupported = ', DatagramSocket.isSupported);
        _udpsocket = new DatagramSocket();
    }
    private var _udpsocket:DatagramSocket;
    private var _dataBacks:Vector.<Function>;
    private var _onLineClients:Array;
    private var _broadCastAddress:String;

    /**
     * 侦听端口，用于接收消息
     * @param port 端口号
     */
    public function listen(port:int):void {
        _udpsocket.bind(port);
        _udpsocket.receive();
    }

    /**
     * 停止侦听端口
     */
    public function unListen():void {
        _udpsocket.close();
    }

    /**
     * 绑定接收消息事件
     * @param func
     */
    public function addDataHandler(func:Function):void {
        _dataBacks ||= new Vector.<Function>();
        if (_dataBacks.indexOf(func) == -1) {
            _dataBacks.push(func);
        }

        if (_udpsocket.hasEventListener(DatagramSocketDataEvent.DATA)) {
            return;
        }
        _udpsocket.addEventListener(DatagramSocketDataEvent.DATA, dataHandler);
    }

    /**
     * 移除绑定接收消息事件
     * @param func
     *
     */
    public function removeDataHandler(func:Function):void {
        var id:int = _dataBacks.indexOf(func);
        if (id != -1) {
            _dataBacks.splice(id, 1);
        }
    }

    /**
     * 发送消息
     * @param ip 目标IP
     * @param port 端口号
     * @param msg 消息内容
     *
     */
    public function send(ip:String, port:int, msg:Object):void {
        log('UDPCtrler.send', ip, port, msg);

        var bytes:ByteArray = UdpPacketUtils.encode(msg);
        _udpsocket.send(bytes, 0, 0, ip, port);
    }

    /**
     * 发送广播消息 (仅限AIR，WINDOWS系统，需要支持打开进程)
     * @param port 端口
     * @param msg 消息内容
     * @param updateOnLineIP 是否更新IP列表
     */
    public function sendBroadcast(port:int, msg:Object):void {
        if (!_broadCastAddress) {
            var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
            for each(var i:NetworkInterface in interfaces) {
                if (i.active) {
                    for each(var j:InterfaceAddress in i.addresses) {
                        if (j.broadcast && j.broadcast != '') {
                            _broadCastAddress = j.broadcast;
                        }
                    }
                }
            }
        }

        if (_broadCastAddress) {
            send(_broadCastAddress, port, msg);
        }
        else {
            TraceLang('debug.trace.data.udp_socket.broadcast_fail');
        }

    }

    private function log(...params):void {
    }

    /**
     * 接收到消息事件响应
     * @param e
     */
    private function dataHandler(e:DatagramSocketDataEvent):void {
        var data:UDPDataVO = UdpPacketUtils.decode(e.data, e.srcAddress, e.srcPort);

        for each(var f:Function in _dataBacks) {
            if (f != null) {
                f(data);
            }
        }
    }

}
}
