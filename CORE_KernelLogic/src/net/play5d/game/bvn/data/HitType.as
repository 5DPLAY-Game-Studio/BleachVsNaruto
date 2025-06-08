/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
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
//攻击类型 只能添加，不能修改对应的数字
public class HitType {
    include '../../../../../../include/_INCLUDE_.as';

    // 没有特效
    public static const NONE:int = 0;

    public static const KAN:int       = 1;
    public static const KAN_HEAVY:int = 6;

    public static const DA:int       = 2;
    public static const DA_HEAVY:int = 3;

    public static const MAGIC:int       = 4;
    public static const MAGIC_HEAVY:int = 5;

    public static const FIRE:int     = 7;
    public static const ICE:int      = 8;
    public static const ELECTRIC:int = 9;
    public static const STONE:int    = 10;

    public static const CATCH:int = 11; //抓住


    private static const heavyTypes:Array = [KAN_HEAVY, DA_HEAVY, MAGIC_HEAVY, FIRE, ICE, ELECTRIC];

    public static function isHeavy(v:int):Boolean {
        return heavyTypes.indexOf(v) != -1;
    }

}
}
