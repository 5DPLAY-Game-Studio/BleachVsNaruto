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

package net.play5d.game.bvn.interfaces {
public interface IGameSpriteCntlr {

    /**
     * 获取目标
     * @return 目标游戏精灵
     */
    function getTarget():IGameSprite;

    /**
     * 获取所有目标的 IGameSprite
     * @param isOnlyAlive 是否仅获取存活的目标
     * @return 目标全部游戏精灵
     */
    function getTargetAll(isOnlyAlive:Boolean = true):Vector.<IGameSprite>;

    /**
     * 获取主人
     * @return 游戏精灵的上层
     */
    function getOwner():IGameSprite;

    /**
     * 获取最上层主人
     * @return 游戏精灵的最上层
     */
    function getOwnerTop():IGameSprite;

    /**
     * 获取自身
     * @return 游戏精灵自身
     */
    function getSelf():IGameSprite;

}
}
