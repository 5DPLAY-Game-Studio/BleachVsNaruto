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
 * 角色被打类型。
 *
 * <p>区分普通被打与击飞两类受击表现。</p>
 *
 * @see FighterActionState
 */
public class FighterHurtType {
    include '../../../../../../../include/ImportVersion.as';

    /** 被打 */
    public static const HURT:int     = 0;
    /** 击飞 */
    public static const HURT_FLY:int = 1;
}
}
