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

package net.play5d.game.bvn.ui
{
	import com.greensock.TweenLite;

	import flash.display.Sprite;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.kyo.display.shapes.Box;

	public class QuickTransUI extends Sprite
	{
		private var _up:Box;
		private var _down:Box;
		private var _center:Number = 0;
		public function QuickTransUI()
		{
			super();

			_center = GameConfig.GAME_SIZE.y/2;

			_up = new Box(GameConfig.GAME_SIZE.x , _center);
			_down = new Box(GameConfig.GAME_SIZE.x , _center);

			addChild(_up);
			addChild(_down);
		}

		public function fadInAndOut(back:Function = null):void{
			fadIn(function():void{
				fadOut(back);
			});
		}

		public function fadIn(back:Function = null):void{
			_up.y = -_center;
			_down.y = GameConfig.GAME_SIZE.y;

			TweenLite.to(_up,0.1,{y:0});
			TweenLite.to(_down,0.1,{y:_center,onComplete:back});
		}

		public function fadOut(back:Function = null):void{
			TweenLite.to(_up,0.1,{y:-_center});
			TweenLite.to(_down,0.1,{y:GameConfig.GAME_SIZE.y,onComplete:back});
		}


	}
}
