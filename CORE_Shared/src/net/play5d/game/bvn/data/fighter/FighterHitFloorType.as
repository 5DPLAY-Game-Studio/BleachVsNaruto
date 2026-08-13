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

package net.play5d.game.bvn.data.fighter {

/**
 * 角色击落地类型公开常量。
 *
 * <p>0=弹起，1=正常落地，2=重落地；供落地表现区分。</p>
 */
public class FighterHitFloorType {
    include '../../../../../../../include/ImportVersion.as';

    /** 弹起（0） */
    public static const TAN:int    = 0;
    /** 正常落地（1） */
    public static const NORMAL:int = 1;
    /** 重落地（2） */
    public static const HEAVY:int  = 2;
}
}
