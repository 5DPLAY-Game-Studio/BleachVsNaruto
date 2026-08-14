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
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.lan.LanMsgType;
import net.play5d.game.bvn.fighter.FighterMain;

/**
 * 锁帧 <code>INPUT_SYNC</code> 状态包编解码。
 *
 * <p>布局：type + frame + round + gameTime + P1/P2 的 hp/qi/x/y（short）。</p>
 *
 * @see LanInputSyncSnapshot
 * @see LockFrameServerLogic
 * @see LockFrameClientLogic
 */
public class LanInputSyncCodec {

    /**
     * 编码服务端状态同步包。
     *
     * @param frame 当前渲染帧。
     * @param round 回合数。
     * @param gameTime 对局时间。
     * @param p1 P1 角色。
     * @param p2 P2 角色。
     * @return 完整 <code>INPUT_SYNC</code> 字节包。
     * @example
     * <listing version="3.0">
     * var bytes:ByteArray = LanInputSyncCodec.encode(frame, round, time, p1, p2);
     * </listing>
     */
    public static function encode(
            frame:int, round:int, gameTime:int, p1:FighterMain, p2:FighterMain
    ):ByteArray {
        var byte:ByteArray = new ByteArray();
        byte.writeByte(LanMsgType.INPUT_SYNC);
        byte.writeShort(frame);
        byte.writeByte(round);
        byte.writeByte(gameTime);

        byte.writeShort(p1.hp << 0);
        byte.writeShort(p1.qi << 0);
        byte.writeShort(p1.x << 0);
        byte.writeShort(p1.y << 0);

        byte.writeShort(p2.hp << 0);
        byte.writeShort(p2.qi << 0);
        byte.writeShort(p2.x << 0);
        byte.writeShort(p2.y << 0);

        return byte;
    }

    /**
     * 解码状态同步包。
     *
     * @param msgArr 完整载荷（含 type 首字节）。
     * @return 快照；类型不符或为空时返回 null。
     * @example
     * <listing version="3.0">
     * var snap:LanInputSyncSnapshot = LanInputSyncCodec.decode(bytes);
     * </listing>
     */
    public static function decode(msgArr:ByteArray):LanInputSyncSnapshot {
        if (!msgArr) {
            return null;
        }

        msgArr.position = 0;
        if (msgArr.readByte() != LanMsgType.INPUT_SYNC) {
            return null;
        }

        var snap:LanInputSyncSnapshot = new LanInputSyncSnapshot();
        snap.frame    = msgArr.readShort();
        snap.round    = msgArr.readByte();
        snap.gameTime = msgArr.readByte();

        snap.p1hp = msgArr.readShort();
        snap.p1qi = msgArr.readShort();
        snap.p1x  = msgArr.readShort();
        snap.p1y  = msgArr.readShort();

        snap.p2hp = msgArr.readShort();
        snap.p2qi = msgArr.readShort();
        snap.p2x  = msgArr.readShort();
        snap.p2y  = msgArr.readShort();

        return snap;
    }

    /**
     * 将快照写回双方角色，并在有血但未存活时复活。
     *
     * @param snap 解码快照。
     * @param p1 P1 角色。
     * @param p2 P2 角色。
     * @example
     * <listing version="3.0">
     * LanInputSyncCodec.applyToFighters(snap, p1, p2);
     * </listing>
     */
    public static function applyToFighters(
            snap:LanInputSyncSnapshot, p1:FighterMain, p2:FighterMain
    ):void {
        p1.hp = snap.p1hp;
        p1.qi = snap.p1qi;
        p1.x  = snap.p1x;
        p1.y  = snap.p1y;

        p2.hp = snap.p2hp;
        p2.qi = snap.p2qi;
        p2.x  = snap.p2x;
        p2.y  = snap.p2y;

        if (p1.hp > 0 && !p1.isAlive) {
            p1.relive();
        }
        if (p2.hp > 0 && !p2.isAlive) {
            p2.relive();
        }
    }
}
}
