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
 * 锁帧服务端对壳层会话的依赖契约。
 *
 * <p>负责 UDP 广播输入/同步载荷，由壳的联机主机控制实现。</p>
 *
 * @example
 * <listing version="3.0">
 * var link:ILanServerLockLink = new MyLANServerCtrl();
 * link.sendUDP(bytes);
 * </listing>
 */
public interface ILanServerLockLink {
    /**
     * 发送 UDP 载荷。
     * @param data 通常为 <code>ByteArray</code>。
     * @example
     * <listing version="3.0">
     * link.sendUDP(bytes);
     * </listing>
     */
    function sendUDP(data:Object):void;
}
}
