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
 * 输入槽位公开常量。
 *
 * <p>跨壳与对局共用的槽位名，传给 <code>IGameInterface.getGameInput</code>。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IGameInterface#getGameInput()
 */
public class GameInputType {
    include '../../../../../../include/ImportVersion.as';

    /** 菜单 */
    public static const MENU:String = 'MENU';
    /** 1P */
    public static const P1:String   = 'P1';
    /** 2P */
    public static const P2:String   = 'P2';
}
}
