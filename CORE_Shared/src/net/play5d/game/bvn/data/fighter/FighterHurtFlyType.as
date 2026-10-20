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
 * 角色被击飞类型公开常量。
 *
 * <p>区分被击飞后的几种受击表现。</p>
 *
 * @see FighterActionState
 * @see FighterHurtType
 */
public class FighterHurtFlyType {
    include '../../../../../../../include/ImportVersion.as';

    /** 没有击飞 */
    public static const NO_HURT_FLY:int = 0;

    /** 击飞 */
    public static const HURT_FLY:int      = 1;
    /** 落地 */
    public static const HURT_FLY_FALL:int = 2;
    /** 弹起 */
    public static const HURT_FLY_TAN:int  = 3;
    /** 倒地 */
    public static const HURT_FLY_LIE:int  = 4;
}
}
