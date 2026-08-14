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

package net.play5d.game.bvn.interfaces.lan {

/**
 * UDP 传输抽象（壳侧实现：AndroidUDP / DatagramSocket）。
 *
 * <p>收包回调签名为 <code>Function(UDPDataVO):void</code>。</p>
 *
 * @example
 * <listing version="3.0">
 * var udp:IUdpTransport = socket;
 * udp.listen(LanPorts.UDP_CLIENT);
 * udp.addDataHandler(onData);
 * </listing>
 * @see net.play5d.game.bvn.data.lan.LanPorts
 * @see net.play5d.game.bvn.data.lan.UDPDataVO
 */
public interface IUdpTransport {
    /**
     * 侦听端口以接收消息。
     *
     * @param port 端口号。
     * @example
     * <listing version="3.0">
     * udp.listen(LanPorts.UDP_CLIENT);
     * </listing>
     */
    function listen(port:int):void;

    /**
     * 停止侦听。
     *
     * @example
     * <listing version="3.0">
     * udp.unListen();
     * </listing>
     */
    function unListen():void;

    /**
     * 注册收包回调。
     *
     * @param func <code>Function(UDPDataVO):void</code>。
     * @example
     * <listing version="3.0">
     * udp.addDataHandler(onData);
     * </listing>
     */
    function addDataHandler(func:Function):void;

    /**
     * 移除收包回调。
     *
     * @param func 先前注册的回调。
     * @example
     * <listing version="3.0">
     * udp.removeDataHandler(onData);
     * </listing>
     */
    function removeDataHandler(func:Function):void;

    /**
     * 向指定地址发送消息。
     *
     * @param ip 目标 IP。
     * @param port 目标端口。
     * @param msg 消息对象。
     * @example
     * <listing version="3.0">
     * udp.send('192.168.1.2', LanPorts.UDP_CLIENT, 'ping');
     * </listing>
     */
    function send(ip:String, port:int, msg:Object):void;

    /**
     * 发送广播消息。
     *
     * @param port 目标端口。
     * @param msg 消息对象。
     * @example
     * <listing version="3.0">
     * udp.sendBroadcast(LanPorts.UDP_CLIENT, 'ping');
     * </listing>
     */
    function sendBroadcast(port:int, msg:Object):void;
}
}
