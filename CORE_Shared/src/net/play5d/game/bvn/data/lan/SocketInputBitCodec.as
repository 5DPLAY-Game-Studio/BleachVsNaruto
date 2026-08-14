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
 * <p>线序从低位到高位：special … up（与历史 <code>toString(2)</code> 解包一致）。</p>
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
     * SocketInputBitCodec.unpack(msg, data);
     * </listing>
     */
    public static function unpack(msg:int, data:SocketInputData):void {
        var ejz:String = msg.toString(2);
        var l:int      = ejz.length;

        data.special    = ejz.charAt(l - 1) == '1';
        data.superSkill = ejz.charAt(l - 2) == '1';
        data.skill      = ejz.charAt(l - 3) == '1';
        data.dash       = ejz.charAt(l - 4) == '1';
        data.jump       = ejz.charAt(l - 5) == '1';
        data.attack     = ejz.charAt(l - 6) == '1';
        data.right      = ejz.charAt(l - 7) == '1';
        data.left       = ejz.charAt(l - 8) == '1';
        data.down       = ejz.charAt(l - 9) == '1';
        data.up         = ejz.charAt(l - 10) == '1';
    }
}
}
