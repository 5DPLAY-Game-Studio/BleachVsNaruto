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
 * 局域网对局同步消息类型公开常量。
 */
public class LanSyncType {
    include '../../../../../../../include/ImportVersion.as';

    /** 对局开始 */
    public static const GAME_START:int  = 3;
    /** 对局结束 */
    public static const GAME_FINISH:int = 4;

    /** 回合开始 */
    public static const ROUND_START:int  = 6;
    /** 回合结束 */
    public static const ROUND_FINISH:int = 7;

}
}
