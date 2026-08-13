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
 * 锁帧用 Socket 输入通道契约。
 *
 * <p>由壳的联机输入实现采集/回写打包键值，供锁帧客户端与服务端逻辑注入。</p>
 *
 * @example
 * <listing version="3.0">
 * var input:ILanSocketInput = socketInput;
 * input.renderInput();
 * var keys:int = input.getSocketData();
 * </listing>
 */
public interface ILanSocketInput {
    /**
     * 采集本机按键到内部缓冲。
     * @example
     * <listing version="3.0">
     * input.renderInput();
     * </listing>
     */
    function renderInput():void;

    /**
     * 取出当前缓冲键值。
     * @return 键位打包值。
     * @example
     * <listing version="3.0">
     * var v:int = input.getSocketData();
     * </listing>
     */
    function getSocketData():int;

    /**
     * 清空缓冲。
     * @example
     * <listing version="3.0">
     * input.resetInput();
     * </listing>
     */
    function resetInput():void;

    /**
     * 写入远端/缓存键值。
     * @param v 键位打包值。
     * @example
     * <listing version="3.0">
     * input.setSocketData(0x1f);
     * </listing>
     */
    function setSocketData(v:int):void;
}
}
