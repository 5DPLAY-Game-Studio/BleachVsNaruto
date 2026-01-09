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
 * 攻击类型
 */
public class HitType {
    include '../../../../../../include/ImportVersion.as';

    /*----------------------------- 静态公有属性 -----------------------------*/

    // 没有特效
    public static const NONE:int = 0;

    // 砍
    public static const KAN:int       = 1;
    // 重砍
    public static const KAN_HEAVY:int = 6;

    // 打
    public static const DA:int       = 2;
    // 重打
    public static const DA_HEAVY:int = 3;

    // 魔法轻击
    public static const MAGIC:int       = 4;
    // 魔法重击
    public static const MAGIC_HEAVY:int = 5;

    // 火焰
    public static const FIRE:int     = 7;
    // 冰冻
    public static const ICE:int      = 8;
    // 雷电
    public static const ELECTRIC:int = 9;
    // 石化
    public static const STONE:int    = 10;

    // 摔技
    public static const CATCH:int = 11;

    /*----------------------------- 静态私有属性 -----------------------------*/

    // 属于重击类型的类型【重砍，重打，魔法重击，火焰，冰冻，雷电】
    private static const _isHeavyTypes:Vector.<int> = (function ():Vector.<int> {
        var heavyTypes:Vector.<int> = new Vector.<int>();
        heavyTypes.push(
                KAN_HEAVY, DA_HEAVY, MAGIC_HEAVY,
                FIRE, ICE, ELECTRIC
        );

        return heavyTypes;
    })();

    /*----------------------------- 静态公有方法 -----------------------------*/

    /**
     * 判断是否为重击类型
     * @param type 类型
     * @return 是否为重击类型
     */
    public static function isHeavy(type:int):Boolean {
        return _isHeavyTypes.indexOf(type) != -1;
    }

    /*----------------------------- 静态私有方法 -----------------------------*/

}
}
