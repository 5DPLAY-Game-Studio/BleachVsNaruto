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

package net.play5d.game.bvn.utils
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;

	public class MCUtils
	{
		include '../../../../../../include/_INCLUDE_.as';

		public static function hasFrameLabel(mc:MovieClip , label:String):Boolean{
			var labels:Array = mc.currentLabels;
			for each(var i:FrameLabel in labels){
				if(i.name == label) return true;
			}
			return false;
		}

		/**
		 * 设置MC色相（-180 - 180）
		 * @param d
		 * @param hue
		 *
		 */
		public static function setHUE(d:DisplayObject, hue:Number = 0):void{
			if(hue == 0){
				d.filters = null;
			}else{
				var filter:ColorMatrixFilter = createHueFilter(hue);
				d.filters = [filter];
			}
		}

//		public static function stopMovieclips(mc:MovieClip):void{
//			try{
//				mc.stopAllMovieClips();
//			}catch(e:Error){
//				trace(e);
//				mc.stop();
//			}
//		}

		private static function createHueFilter(n:Number):ColorMatrixFilter
		{
			const p1:Number = Math.cos(n * Math.PI / 180);
			const p2:Number = Math.sin(n * Math.PI / 180);
			const p4:Number = 0.213;
			const p5:Number = 0.715;
			const p6:Number = 0.072;
			return new ColorMatrixFilter([p4 + p1 * (1 - p4) + p2 * (0 - p4), p5 + p1 * (0 - p5) + p2 * (0 - p5), p6 + p1 * (0 - p6) + p2 * (1 - p6), 0, 0, p4 + p1 * (0 - p4) + p2 * 0.143, p5 + p1 * (1 - p5) + p2 * 0.14, p6 + p1 * (0 - p6) + p2 * -0.283, 0, 0, p4 + p1 * (0 - p4) + p2 * (0 - (1 - p4)), p5 + p1 * (0 - p5) + p2 * p5, p6 + p1 * (1 - p6) + p2 * p6, 0, 0, 0, 0, 0, 1, 0]);
		}

	}
}
