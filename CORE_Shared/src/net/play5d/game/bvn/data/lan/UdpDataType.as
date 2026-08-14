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
 * UDP 载荷在 <code>UDPDataVO</code> 内的数据类型公开常量。
 *
 * <p>本类常量为解码后的 API 取值，供 <code>UDPDataVO.dataType</code> 使用。
 * 线格式首字节由 <code>UdpPacketUtils</code> 解析后再映射到本常量：
 * 线字节 1→<code>STRING</code>、2→<code>BYTEARRAY</code>、3→<code>OBJECT</code>。
 * 因此 <code>BYTEARRAY</code>/<code>STRING</code> 的数值与线字节对调，切勿把本常量当线首字节写入。</p>
 *
 * @see UDPDataVO
 * @see UdpPacketUtils
 */
public class UdpDataType {
    include '../../../../../../../include/ImportVersion.as';

    /** 二进制载荷 */
    public static const BYTEARRAY:int = 1;
    /** UTF 字符串 */
    public static const STRING:int    = 2;
    /** AMF 对象 */
    public static const OBJECT:int    = 3;
}
}
