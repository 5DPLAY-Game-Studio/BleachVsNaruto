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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;

	public class BlackBackView extends Sprite
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _bishaFace:BishaFaceEffectView;
		private var isRenderFadIn:Boolean;
		private var isRenderFadOut:Boolean;

		private var _bg:Bitmap;

		public function BlackBackView()
		{
			super();

			var bd:BitmapData = new BitmapData(GameConfig.GAME_SIZE.x/10 , GameConfig.GAME_SIZE.y/10 , false , 0);
			_bg = new Bitmap(bd);
			_bg.width = GameConfig.GAME_SIZE.x;
			_bg.height = GameConfig.GAME_SIZE.y;

			addChild(_bg);
		}

		public function destory():void{
			if(_bg){
				try{
					removeChild(_bg);
				}catch(e:Error){}
				_bg.bitmapData.dispose();
				_bg = null;
			}
			removeBishaFace();
		}

//		public function render():void{
//
//		}

		public function renderAnimate():void{
//			if(isRenderFadIn) renderFadIn();
//			if(isRenderFadOut) renderFadOut();
		}

		public function fadIn():void{
//			isRenderFadIn = true;
//			this.alpha = 0;
//			this.visible = true;
		}

		public function fadOut():void{
//			isRenderFadOut = true;
//			this.alpha = 1;
//			this.visible = false;
			removeBishaFace();
			try{
				parent.removeChild(this);
			}catch(e:Error){}
		}

//		private function renderFadIn():void{
//			this.alpha += 0.1;
//			if(alpha >= 1){
//				isRenderFadIn = false;
//			}
//		}
//
//		private function renderFadOut():void{
//			this.alpha -= 0.1;
//			if(alpha <= 0){
//				isRenderFadOut = false;
//
//				removeBishaFace();
//
//			}
//		}


		public function showBishaFace(faceid:int , face:DisplayObject):void{
			if(!_bishaFace){
				_bishaFace = new BishaFaceEffectView();
				var zoom:Number = 1;
				if(GameCtrl.I && GameCtrl.I.gameState && GameCtrl.I.gameState.camera){
					zoom = GameCtrl.I.gameState.camera.getZoom();
				}
				_bishaFace.mc.y = 100 + (100 / zoom);
				addChild(_bishaFace.mc);
			}

			_bishaFace.setFace(faceid , face);
			_bishaFace.fadIn();
		}

		private function removeBishaFace():void{
			if(_bishaFace){
				_bishaFace.destory();
				_bishaFace = null;
			}
		}


	}
}
