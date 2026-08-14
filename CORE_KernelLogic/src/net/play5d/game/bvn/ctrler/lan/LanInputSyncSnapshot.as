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

/**
 * 锁帧 <code>INPUT_SYNC</code> 解码快照。
 *
 * @see LanInputSyncCodec
 */
public class LanInputSyncSnapshot {

    /**
     * 服务端帧号。
     */
    public var frame:int;
    /**
     * 回合数。
     */
    public var round:int;
    /**
     * 对局剩余时间。
     */
    public var gameTime:int;

    /**
     * P1 生命。
     */
    public var p1hp:int;
    /**
     * P1 气。
     */
    public var p1qi:int;
    /**
     * P1 X。
     */
    public var p1x:int;
    /**
     * P1 Y。
     */
    public var p1y:int;

    /**
     * P2 生命。
     */
    public var p2hp:int;
    /**
     * P2 气。
     */
    public var p2qi:int;
    /**
     * P2 X。
     */
    public var p2x:int;
    /**
     * P2 Y。
     */
    public var p2y:int;
}
}
