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

package net.play5d.game.bvn.fighter.vos
{
	import net.play5d.game.bvn.GameConfig;

	public class FighterBuffVO
	{
		include "_INCLUDE_.as";

		public var param:String;
		public var resumeValue:Number = 0;
		public var finished:Boolean = false;

		private var _holdFrame:Number = 1;
		public function FighterBuffVO(param:String, hold:Number = 1)
		{
			this.param = param;
			//		this.value = value;
			this._holdFrame = hold * GameConfig.FPS_GAME;
			this.finished = false;
		}

		public function setHold(v:Number):void{
			this._holdFrame = v * GameConfig.FPS_GAME;
			this.finished = false;
		}

		public function render():Boolean{

			if(finished) return true;

			if(--_holdFrame <= 0){
				finished = true;
				return true;
			}
			return false;
		}

	}
}
