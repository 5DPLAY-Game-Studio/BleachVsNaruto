/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ide.utils {
import flash.utils.getDefinitionByName;

import net.play5d.game.bvn.ide.data.GamePKGName;

/**
 * 游戏元件相关实用工具
 */
public class GameSpriteUtils {

    /**
     * 获取游戏元件类
     * @param type 类型
     * @return 指定游戏元件类
     */
    public static function getGameSpriteClass(type:String):Class {
        var cls:Class = getDefinitionByName(GamePKGName.FIGHTER + type) as Class;

        return cls;
    }

    /**
     * 获取游戏类
     * @param name 类的全限定名称
     * @return 指定类
     */
    public static function getGameClass(name:String):Class {
        var cls:Class = getDefinitionByName(name) as Class;

        return cls;
    }
}
}
