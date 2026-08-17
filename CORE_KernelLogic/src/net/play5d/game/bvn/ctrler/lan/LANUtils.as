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
import net.play5d.game.bvn.GameConfig;
import net.play5d.kyo.utils.KyoTimerFormat;

/**
 * 局域网锁帧 / 同步间隔参数（按平台 <code>configure</code> 后随 FPS 缩放）。
 *
 * <p>默认与 PC 壳一致：<code>syncGapBase = 30 * 3</code>。移动端应在开局前调用
 * <code>configure(30 * 5, 8)</code>。</p>
 *
 * @see #configure()
 * @see #updateParams()
 */
public class LANUtils {
    /** @private 锁帧关键帧（基准 30FPS） */
    private static const _LOCK_KEYFRAME:int = 3;

    /** @private 同步状态发送间隔基准帧数 */
    private static var _syncGapBase:int = 30 * 3;

    /** 当前锁帧关键帧（已按 FPS 缩放） */
    public static var LOCK_KEYFRAME:int = _LOCK_KEYFRAME;
    /** 当前同步间隔（已按 FPS 缩放） */
    public static var SYNC_GAP:int      = _syncGapBase;

    /**
     * 输入包标识字节（移动端乐观锁帧使用；PC 默认 0）。
     * @default 0
     */
    public static var INPUT_KEY:int = 0;

    /**
     * 配置平台相关基准参数，并重置公开缩放值到基准。
     * @param syncGapBase 同步间隔基准帧（30FPS 下）。
     * @param inputKey 输入包标识；不需要时传 0。
     */
    public static function configure(syncGapBase:int, inputKey:int = 0):void {
        _syncGapBase = syncGapBase;
        INPUT_KEY    = inputKey;
        LOCK_KEYFRAME = _LOCK_KEYFRAME;
        SYNC_GAP      = _syncGapBase;
    }

    /**
     * 按当前 <code>GameConfig.FPS_GAME</code> 相对 30FPS 缩放锁帧参数。
     */
    public static function updateParams():void {
        var rate:Number = GameConfig.FPS_GAME / 30;
        LOCK_KEYFRAME   = _LOCK_KEYFRAME * rate;
        SYNC_GAP        = _syncGapBase * rate;
    }

    /**
     * 格式化主机列表时间显示。
     * @param date 时间。
     * @return <code>MM/DD HH:mm</code>。
     * @see KyoTimerFormat#getMonthDayTime()
     */
    public static function getTimeStr(date:Date):String {
        return KyoTimerFormat.getMonthDayTime(date);
    }

}
}
