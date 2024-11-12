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

package net.play5d.game.bvn.data.mosou
{
	public class LevelModel
	{
		include "_INCLUDE_.as";

		/**
		 * 角色升级需要的经验值
		 */
		public static function getLevelUpExp(level:int):int{
			if(level <= 0) return 0;

			function solveExp(level:int):int{
				var n:int = level;
				var exp:int = ((3.8 * n * n) - ( 1.2 * n )) + 48.6;
				return exp;
			}

			var exp:int = solveExp(level);

			if(level > 1){
				for(var i:int = 1 ; i < level ; i++){
					exp += solveExp(i);
				}
			}

			return exp;
		}

	}
}
