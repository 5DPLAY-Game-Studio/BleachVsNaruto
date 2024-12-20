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

package net.play5d.game.bvn.views.effects
{
	import com.greensock.TweenLite;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import net.play5d.game.bvn.ctrler.AssetManager;

	public class BishaFaceEffectView
	{
		include '../../../../../../../include/_INCLUDE_.as';

		public var mc:MovieClip;
		private var _faceObj:Object = {};
		public function BishaFaceEffectView()
		{
			mc = AssetManager.I.getEffect("bisha_face_mc");
		}

		/**
		 * 设置角色图
		 * @param faceId 1 | 2
		 * @param face
		 */
		public function setFace(faceId:int , face:DisplayObject):void{
			var facemc:MovieClip = mc['facemc'+faceId];
			if(!facemc) return;

			_faceObj[faceId] = face;
			face.width = 254;
			face.height = 180;
			facemc.addChild(face);
		}

		public function fadIn():void{
			mc.gotoAndPlay(2);
		}

		public function destory():void{
			for each(var i:DisplayObject in _faceObj){
				if(i is Bitmap) (i as Bitmap).bitmapData.dispose();
			}
		}


	}
}
