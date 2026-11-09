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

package net.play5d.game.bvn.data {

/**
 * 画质档位公开常量。
 *
 * <p>跨壳设置与对局共用的档位字符串，写入配置的 <code>quality</code> 字段。</p>
 */
public class GameQuality {
    include '../../../../../../include/ImportVersion.as';

    /**
     * 低。
     *
     * @default low
     */
    public static const LOW:String    = 'low';
    /**
     * 中。
     *
     * @default medium
     */
    public static const MEDIUM:String = 'medium';
    /**
     * 高。
     *
     * @default high
     */
    public static const HIGH:String   = 'high';
    /**
     * 更高。
     *
     * @default higher
     */
    public static const HIGHER:String = 'higher';
    /**
     * 最高。
     *
     * @default best
     */
    public static const BEST:String   = 'best';
}
}
