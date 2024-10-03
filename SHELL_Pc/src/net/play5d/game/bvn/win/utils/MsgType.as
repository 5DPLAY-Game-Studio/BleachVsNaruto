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

package net.play5d.game.bvn.win.utils
{
	public class MsgType
	{

		public static const CHART:String = "CHART";

		public static const START_GAME:String = "START_GAME";

		public static const JOIN:String = "JOIN";
		public static const JOIN_IN:String = "JOIN_IN";
		public static const JOIN_BACK:String = "JOIN_BACK";

		public static const FIND_HOST:String = "FIND_HOST";
		public static const FIND_HOST_BACK:String = "FIND_HOST_BACK";

		public static const KICK_OUT:String = "KICK_OUT";

		public static const INPUT_SEND:int = 8;
		public static const INPUT_UPDATE:int = 9;
		public static const INPUT_SYNC:int = 10;

		public function MsgType()
		{
		}
	}
}
