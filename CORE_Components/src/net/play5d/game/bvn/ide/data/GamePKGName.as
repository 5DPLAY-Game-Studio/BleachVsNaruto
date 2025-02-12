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

package net.play5d.game.bvn.ide.data {

/**
 * 游戏包名
 */
public class GamePKGName {

    // 包路径前缀
    private static const PREF:String = 'net.play5d.game.bvn.';
    // 包路径后缀
    private static const SUF:String = '::';

    // fighter
    public static const FIGHTER       :String = PREF + 'fighter' + SUF;
    // ctrler.game_ctrls
    public static const CTRLER_GAMECTRLS:String = PREF + 'ctrler.game_ctrls' + SUF;

}
}
