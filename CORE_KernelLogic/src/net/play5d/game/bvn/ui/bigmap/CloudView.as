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

package net.play5d.game.bvn.ui.bigmap
{
	import flash.display.MovieClip;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.utils.ResUtils;

	public class CloudView
	{
		public var speed:Number = 0;
		public var mc:MovieClip;

		public function CloudView(X:Number, Y:Number)
		{
			mc = ResUtils.I.createDisplayObject(ResUtils.swfLib.bigMap, 'cloud_mc');
//			mc.x = (20 - mc.width) + (GameConfig.GAME_SIZE.x - 50) * Math.random();
			mc.x = X;
			mc.y = Y;
			mc.alpha = 0.2 + Math.random() * 0.3;
			mc.gotoAndStop(1 + int(Math.random() * mc.totalFrames));
			speed = 0.02 + Math.random() * 0.1;

//			trace('addCloud::', mc.x, mc.y, mc.alpha, mc.currentFrame, speed);
		}

		public function render():Boolean{
			mc.y -= speed;
			return mc.y < -mc.height + 30;
		}

	}
}
