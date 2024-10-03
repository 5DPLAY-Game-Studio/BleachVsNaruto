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
	import net.play5d.game.bvn.GameConfig;

	public class LANUtils
	{
		/**
		 * 锁帧，关键帧
		 */
		private static const _LOCK_KEYFRAME:int = 3;

//		public static const CLIENT_SEND_CTRL_GAP:int = 30;

//		public static const SERVER_WAIT_CLIENT:int = 30;

		/**
		 * 发送同步状态数据间隔
		 */
		private static const _SYNC_GAP:int = 30 * 3;

		public static var LOCK_KEYFRAME:int = _LOCK_KEYFRAME;
		public static var SYNC_GAP:int = _SYNC_GAP;

		public function LANUtils()
		{
		}

		public static function updateParams():void{
			var rate:Number = GameConfig.FPS_GAME / 30;
			LOCK_KEYFRAME = _LOCK_KEYFRAME * rate;
			SYNC_GAP = _SYNC_GAP * rate;
		}

		public static function getTimeStr(date:Date):String{
			return formatNum(date.month+1) + "/" + formatNum(date.date) + " " + formatNum(date.hours) + ":" + formatNum(date.minutes);
		}

		private static function formatNum(num:int):String{
			if(num < 10) return '0'+num;
			return num.toString();
		}

	}
}
