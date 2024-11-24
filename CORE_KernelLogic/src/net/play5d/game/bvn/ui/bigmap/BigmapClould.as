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
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.GameConfig;

	public class BigmapClould extends Sprite
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _clouds:Vector.<CloudView> = new Vector.<CloudView>();
		private var _createFrame:int;
		private var _bounds:Rectangle;

		public function BigmapClould(bounds:Rectangle)
		{
			super();
			_bounds = bounds;
			mouseChildren = mouseEnabled = false;
		}

		public function init():void{
			for(var i:int = _bounds.y + 100; i < _bounds.height; i+= 50){
				addCloud(getRandomX() , i);
			}
		}

		public function destory():void{
			if(_clouds){
				for each(var i:CloudView in _clouds){
					try{
						this.removeChild(i.mc);
					}catch(e:Error){}
				}
				_clouds = null;
			}
		}

		public function render():void{
			for each(var i:CloudView in _clouds){
				if(i.render()){
					try{
						trace('remove cloud');
						var index:int = _clouds.indexOf(i);
						if(index != -1) _clouds.splice(_clouds.indexOf(i), 1);
						this.removeChild(i.mc);
					}catch(e:Error){
						trace('BigmapClould', e);
					}
				}
			}

			if(--_createFrame < 0){
				addCloud();
				_createFrame = 5 * GameConfig.FPS_UI;
			}
		}

		private function addCloud(X:Number = 0, Y:Number = 0):void{
			if(X == 0) X = getRandomX();
			if(Y == 0) Y = _bounds.y + _bounds.height + 100;

			var v:CloudView = new CloudView(X, Y);
			this.addChild(v.mc);
			_clouds.push(v);
		}

		private function getRandomX():Number{
			return _bounds.x + ( (_bounds.width / 20) * (Math.random() * 20) ) - 100;
		}

//		private function getRandomY():Number{
//			return _bounds.y + ( (_bounds.height / 20) * (Math.random() * 20) );
//		}

	}
}
