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

/**
 * 局域网默认端口常量（跨壳一致）。
 */
public class LanPorts {
    include '../../../../../../../include/ImportVersion.as';

    /** UDP 主机广播 / 发现端口 */
    public static const UDP_SERVER:int = 17477;
    /** UDP 客户端侦听端口 */
    public static const UDP_CLIENT:int = 17478;
    /** TCP 会话端口 */
    public static const TCP:int = 17511;
}
}
