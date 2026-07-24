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

package net.play5d.game.bvn {

use namespace bvn_internal;

/**
 * 游戏版本号对外入口。
 *
 * <p>对外暴露 <code>bvn_internal::VERSION</code>，供运行时与资源侧版本校验使用。</p>
 *
 * @see bvn_internal
 */
public class GameVersion {
    include '../../../../../include/ImportVersion.as';

    /**
     * 当前共享库版本号。
     * @default 见 <code>ImportVersion.as</code>
     */
    public static const VERSION:String = bvn_internal::VERSION;
}
}
