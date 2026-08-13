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
 * 局域网选人阶段数据包类型公开常量。
 */
public class SelectFighterDataType {
    include '../../../../../../../include/ImportVersion.as';

    /** 选人包键 */
    public static const KEY:String = 'SELECT';

    /** 选择角色 */
    public static const SELECT:int         = 1;
    /** 进入下一步 */
    public static const NEXT_STEP:int      = 2;
    /** 选人完成 */
    public static const FIGHTER_FINISH:int = 3;
    /** 选择出战顺序 */
    public static const INDEX:int          = 4;
    /** 出战顺序完成 */
    public static const INDEX_FINISH:int   = 5;

}
}
