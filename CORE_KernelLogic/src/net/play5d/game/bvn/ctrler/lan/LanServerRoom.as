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

package net.play5d.game.bvn.ctrler.lan {
import flash.net.Socket;

import net.play5d.game.bvn.data.lan.ClientVO;

/**
 * 局域网主机房间成员。
 *
 * <p>只保留一名客户端。套接字收发和房间界面由壳负责。</p>
 *
 * @see net.play5d.game.bvn.data.lan.ClientVO
 */
public class LanServerRoom {

    /** @private */
    private var _clients:Vector.<ClientVO> = new Vector.<ClientVO>();

    /**
     * 当前客户端列表。
     *
     * @return 成员向量。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;ClientVO&gt; = room.clients;
     * </listing>
     */
    public function get clients():Vector.<ClientVO> {
        return _clients;
    }

    /**
     * 接受一名客户端。已有成员时拒绝。
     *
     * @param ip 地址。
     * @param name 显示名。
     * @param socket TCP 套接字。
     * @return 新成员；房间已满时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var client:ClientVO = room.accept(ip, name, socket);
     * </listing>
     */
    public function accept(ip:String, name:String, socket:Socket):ClientVO {
        if (_clients.length > 0) {
            return null;
        }

        var client:ClientVO = new ClientVO();
        client.ip           = ip;
        client.name         = name;
        client.socket       = socket;
        _clients.push(client);

        return client;
    }

    /**
     * 按套接字查找成员。
     *
     * @param socket TCP 套接字。
     * @return 成员；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var client:ClientVO = room.find(socket);
     * </listing>
     */
    public function find(socket:Socket):ClientVO {
        for each(var client:ClientVO in _clients) {
            if (client.socket == socket) {
                return client;
            }
        }

        return null;
    }

    /**
     * 按套接字移除成员。
     *
     * @param socket TCP 套接字。
     * @return 被移除的成员；没有时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * room.remove(socket);
     * </listing>
     */
    public function remove(socket:Socket):ClientVO {
        for (var i:int = 0; i < _clients.length; i++) {
            if (_clients[i].socket == socket) {
                var client:ClientVO = _clients[i];
                _clients.splice(i, 1);

                return client;
            }
        }

        return null;
    }

    /**
     * 清空成员。
     *
     * @example
     * <listing version="3.0">
     * room.clear();
     * </listing>
     */
    public function clear():void {
        _clients = new Vector.<ClientVO>();
    }

    /**
     * 对每个成员执行回调。
     *
     * @param fn 签名为 <code>function(client:ClientVO):void</code>。
     * @example
     * <listing version="3.0">
     * room.each(function (client:ClientVO):void {
     * });
     * </listing>
     */
    public function each(fn:Function):void {
        for each(var client:ClientVO in _clients) {
            fn(client);
        }
    }
}
}
