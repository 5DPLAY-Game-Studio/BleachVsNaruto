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
import net.play5d.game.bvn.interfaces.lan.ILanSocketInput;

/**
 * 锁帧输入帧缓存填充与回放。
 *
 * @see LockFrameServerLogic
 * @see LockFrameClientLogic
 */
public class LockFrameInputCache {

    /**
     * 将一段帧区间写入缓存为 <code>[serverK, clientK]</code>。
     *
     * @param cache 帧号到键位对的映射。
     * @param fromFrame 起始帧（含）。
     * @param toFrame 结束帧（不含）。
     * @param serverK 服务端键位打包值。
     * @param clientK 客户端键位打包值。
     * @example
     * <listing version="3.0">
     * LockFrameInputCache.fill(cache, frame, next, serverK, clientK);
     * </listing>
     */
    public static function fill(
            cache:Object, fromFrame:int, toFrame:int, serverK:int, clientK:int
    ):void {
        for (var i:int = fromFrame; i < toFrame; i++) {
            cache[i] = [serverK, clientK];
        }
    }

    /**
     * 按帧号将缓存键位写回双方输入通道。
     *
     * @param cache 帧缓存。
     * @param frame 当前帧。
     * @param inputP1 P1 通道。
     * @param inputP2 P2 通道。
     * @example
     * <listing version="3.0">
     * LockFrameInputCache.apply(cache, frame, inputP1, inputP2);
     * </listing>
     */
    public static function apply(
            cache:Object, frame:int, inputP1:ILanSocketInput, inputP2:ILanSocketInput
    ):void {
        var cacheKeys:Array = cache[frame];
        if (cacheKeys) {
            inputP1.setSocketData(cacheKeys[0]);
            inputP2.setSocketData(cacheKeys[1]);
        }
    }
}
}
