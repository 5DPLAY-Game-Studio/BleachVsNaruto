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
import flash.utils.ByteArray;

/**
 * UDP 线格式编解码（对外静态工具）。
 *
 * <p>Pc/Mob 共用线布局：首字节类型 + 载荷（1=字符串、2=二进制、3=对象）。
 * 解码结果写入 <code>UDPDataVO</code>，类型映射为 <code>UdpDataType</code>。
 * 仅做字节变换，不含网络收发。</p>
 *
 * @see UDPDataVO
 * @see UdpDataType
 */
public class UdpPacketUtils {
    include '../../../../../../../include/ImportVersion.as';

    /** @private 线格式：字符串 */
    private static const WIRE_STRING:int = 1;
    /** @private 线格式：二进制 */
    private static const WIRE_BYTEARRAY:int = 2;
    /** @private 线格式：对象 */
    private static const WIRE_OBJECT:int = 3;

    /**
     * 将消息编码为 UDP 载荷。
     * @param msg 字符串 / <code>ByteArray</code> / 其它对象。
     * @param maxLength 最大字节数；&lt;0 不限制。
     * @return 编码后的字节（position=0）。
     * @throws Error 超出 <code>maxLength</code>。
     * @example
     * <listing version="3.0">
     * var bytes:ByteArray = UdpPacketUtils.encode('ping', 512);
     * </listing>
     */
    public static function encode(msg:Object, maxLength:int = -1):ByteArray {
        var bytes:ByteArray = new ByteArray();
        if (msg is String) {
            bytes.writeByte(WIRE_STRING);
            bytes.writeUTFBytes(msg as String);
        }
        else if (msg is ByteArray) {
            bytes.writeByte(WIRE_BYTEARRAY);
            bytes.writeBytes(msg as ByteArray, 0, (msg as ByteArray).bytesAvailable);
        }
        else {
            bytes.writeByte(WIRE_OBJECT);
            bytes.writeObject(msg);
        }
        bytes.position = 0;

        if (maxLength >= 0 && bytes.length > maxLength) {
            throw new Error('byteArray.length is over buffer length!');
        }

        return bytes;
    }

    /**
     * 解析 UDP 收包为 VO。
     * @param byte 含线类型首字节的数据。
     * @param fromIP 发送方 IP。
     * @param fromPort 发送方端口。
     * @return 封装后的 VO。
     * @example
     * <listing version="3.0">
     * var vo:UDPDataVO = UdpPacketUtils.decode(bytes, '192.168.1.2', 8080);
     * </listing>
     */
    public static function decode(byte:ByteArray, fromIP:String, fromPort:int):UDPDataVO {
        var data:UDPDataVO = new UDPDataVO();
        data.fromIP        = fromIP;
        data.fromPort      = fromPort;

        var type:int = byte.readByte();
        switch (type) {
        case WIRE_STRING:
            data.dataType = UdpDataType.STRING;
            data.setData(byte.readUTFBytes(byte.bytesAvailable));
            break;
        case WIRE_BYTEARRAY:
            data.dataType         = UdpDataType.BYTEARRAY;
            var payload:ByteArray = new ByteArray();
            payload.writeBytes(byte, 1, byte.bytesAvailable);
            payload.position = 0;
            data.setData(payload);
            break;
        case WIRE_OBJECT:
            data.dataType = UdpDataType.OBJECT;
            data.setData(byte.readObject());
            break;
        }

        return data;
    }
}
}
