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

package net.play5d.game.bvn.win.utils {
public class LanSyncType {

//		public static const SELECT_START:int = 0;
//		public static const SELECT_FIGHTER:int = 1;
//		public static const SELECT_FIGHTER_INDEX:int = 2;

    public static const GAME_START:int  = 3;
    public static const GAME_FINISH:int = 4;
//		public static const GAME_RENDER:int = 5;

    public static const ROUND_START:int  = 6;
    public static const ROUND_FINISH:int = 7;

    public function LanSyncType() {
    }
}
}
