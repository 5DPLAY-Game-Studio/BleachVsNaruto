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
 * Socket 锁帧按键整数与 <code>SocketInputData</code> 位解包。
 *
 * <p>跨壳锁帧共用的按键缓冲形状：将打包整数按历史 <code>toString(2)</code>
 * 线序写入 <code>SocketInputData</code>（从低位到高位：special … up）。
 * 仅做位变换，不含网络收发。</p>
 *
 * @see SocketInputData
 */
public class SocketInputBitCodec {
    include '../../../../../../../include/ImportVersion.as';

    /**
     * 将打包整数解包写入缓冲。
     *
     * @param msg 打包后的按键整数。
     * @param data 写入目标。
     * @example
     * <listing version="3.0">
     * var data:SocketInputData = new SocketInputData();
     * SocketInputBitCodec.unpack(1, data); // '1' → special
     * data.special; // true
     * SocketInputBitCodec.unpack(33, data); // '100001' → special + attack
     * </listing>
     */
    public static function unpack(msg:int, data:SocketInputData):void {
        var bits:String = msg.toString(2);
        var bitLen:int  = bits.length;

        data.special    = bits.charAt(bitLen - 1) == '1';
        data.superSkill = bits.charAt(bitLen - 2) == '1';
        data.skill      = bits.charAt(bitLen - 3) == '1';
        data.dash       = bits.charAt(bitLen - 4) == '1';
        data.jump       = bits.charAt(bitLen - 5) == '1';
        data.attack     = bits.charAt(bitLen - 6) == '1';
        data.right      = bits.charAt(bitLen - 7) == '1';
        data.left       = bits.charAt(bitLen - 8) == '1';
        data.down       = bits.charAt(bitLen - 9) == '1';
        data.up         = bits.charAt(bitLen - 10) == '1';
    }
}
}
