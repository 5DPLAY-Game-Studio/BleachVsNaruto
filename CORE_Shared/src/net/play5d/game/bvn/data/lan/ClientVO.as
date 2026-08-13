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

package net.play5d.game.bvn.data.lan {
import flash.net.Socket;

/**
 * 局域网已连接客户端公开数据。
 *
 * <p>跨壳共用的房间客户端形状：地址、显示名与可选 TCP 套接字引用。
 * <code>socket</code> 仅作会话绑定字段，由壳在接入时赋值；本库不负责收发。</p>
 */
public class ClientVO {
    /**
     * 构造空客户端 VO。
     * @example
     * <listing version="3.0">
     * var client:ClientVO = new ClientVO();
     * client.ip = '192.168.1.2';
     * </listing>
     */
    public function ClientVO() {
    }

    /**
     * 客户端 IP。
     * @default null
     */
    public var ip:String;
    /**
     * 客户端端口。
     * @default 0
     */
    public var port:int;
    /**
     * 显示名。
     * @default null
     */
    public var name:String;
    /**
     * 壳侧 TCP 套接字引用（会话绑定；可为 <code>null</code>）。
     * @default null
     */
    public var socket:Socket;

    /**
     * 客户端标识（当前等于 <code>ip</code>）。
     * @return 标识字符串。
     * @example
     * <listing version="3.0">
     * client.ip = '192.168.1.2';
     * client.id; // '192.168.1.2'
     * </listing>
     * @see #ip
     */
    public function get id():String {
        return ip;
    }
}
}
