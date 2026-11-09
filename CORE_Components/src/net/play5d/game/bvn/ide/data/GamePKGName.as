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

package net.play5d.game.bvn.ide.data {

/**
 * 游戏包名常量。
 *
 * <p>用于 <code>getDefinitionByName</code> 拼接全限定类名。</p>
 */
public class GamePKGName {

    /** @private 包路径前缀 */
    private static const PREF:String = 'net.play5d.game.bvn.';

    /** @private 包路径后缀 */
    private static const SUF:String = '::';

    /**
     * fighter 包路径前缀。
     *
     * @default net.play5d.game.bvn.fighter::
     */
    public static const FIGHTER:String = PREF + 'fighter' + SUF;

    /**
     * ctrler.game_ctrls 包路径前缀。
     *
     * @default net.play5d.game.bvn.ctrler.game_ctrls::
     */
    public static const CTRLER_GAMECTRLS:String = PREF + 'ctrler.game_ctrls' + SUF;
}
}
