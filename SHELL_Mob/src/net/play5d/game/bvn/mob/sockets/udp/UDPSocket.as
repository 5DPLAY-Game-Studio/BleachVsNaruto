/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.mob.sockets.udp {
import flash.events.DatagramSocketDataEvent;
import flash.net.DatagramSocket;
import flash.net.InterfaceAddress;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.lan.UDPDataVO;
import net.play5d.game.bvn.data.lan.UdpHandlerList;
import net.play5d.game.bvn.data.lan.UdpPacketUtils;
import net.play5d.game.bvn.interfaces.lan.IUdpTransport;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * UDP 协议收发（Mob / <code>DatagramSocket</code>）。
 *
 * <p>AIR 3.8 起 Android 支持 <code>DatagramSocket</code>。运行时不支持时收发为空操作。</p>
 *
 * @see net.play5d.game.bvn.interfaces.lan.IUdpTransport
 */
public class UDPSocket implements IUdpTransport {
    public function UDPSocket() {
        if (!DatagramSocket.isSupported) {
            GameLogger.error('net', 'DatagramSocket is not supported');
            return;
        }
        _udpsocket = new DatagramSocket();
    }
    private var _udpsocket:DatagramSocket;
    private var _handlers:UdpHandlerList;
    private var _broadCastAddress:String;

    /**
     * 侦听端口，用于接收消息。
     * @param port 端口号。
     */
    public function listen(port:int):void {
        if (!_udpsocket) {
            return;
        }
        _udpsocket.bind(port);
        _udpsocket.receive();
    }

    /**
     * 停止侦听端口。
     */
    public function unListen():void {
        if (!_udpsocket) {
            return;
        }
        _udpsocket.close();
    }

    /**
     * 绑定接收消息事件。
     * @param func <code>Function(UDPDataVO):void</code>。
     */
    public function addDataHandler(func:Function):void {
        _handlers ||= new UdpHandlerList();
        _handlers.add(func);

        if (!_udpsocket || _udpsocket.hasEventListener(DatagramSocketDataEvent.DATA)) {
            return;
        }
        _udpsocket.addEventListener(DatagramSocketDataEvent.DATA, dataHandler);
    }

    /**
     * 移除绑定接收消息事件。
     * @param func 先前注册的回调。
     */
    public function removeDataHandler(func:Function):void {
        _handlers && _handlers.remove(func);
    }

    /**
     * 发送消息。
     * @param ip 目标 IP。
     * @param port 端口号。
     * @param msg 消息内容。
     */
    public function send(ip:String, port:int, msg:Object):void {
        if (!_udpsocket) {
            return;
        }
        var bytes:ByteArray = UdpPacketUtils.encode(msg);
        _udpsocket.send(bytes, 0, 0, ip, port);
    }

    /**
     * 发送广播消息。
     * @param port 端口。
     * @param msg 消息内容。
     */
    public function sendBroadcast(port:int, msg:Object):void {
        if (!_udpsocket) {
            return;
        }
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
            TraceLang('udp_socket.broadcast_fail');
        }
    }

    /** @private */
    private function dataHandler(e:DatagramSocketDataEvent):void {
        var data:UDPDataVO = UdpPacketUtils.decode(e.data, e.srcAddress, e.srcPort);
        _handlers && _handlers.dispatch(data);
    }

}
}
