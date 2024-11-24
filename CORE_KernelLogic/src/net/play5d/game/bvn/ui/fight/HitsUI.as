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

package net.play5d.game.bvn.ui.fight
{
	import flash.display.MovieClip;
	import flash.geom.Point;

	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;

	public class HitsUI
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _mc:MovieClip;
		private var _txtmc:MCNumber;
		private var _isShow:Boolean;
		private var _orgPos:Point;
		public function HitsUI(mc:MovieClip)
		{
			_mc = mc;
			var cls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight , 'hits_num_mc');
			_txtmc = new MCNumber(cls,0,1,35);
			_orgPos = new Point(mc.x , mc.y);
			_mc.ct.addChild(_txtmc);
		}

		public function destory():void{
			if(_txtmc){
				try{
					_mc.ct.removeChild(_txtmc);
				}catch(e:Error){}
				_txtmc = null;
			}

			if(_mc){
				_mc = null;
			}

			_orgPos = null;
//			_mc.gotoAndStop('destory');
		}

		public function show(num:int):void{
			_txtmc.number = num;

			var xoffset:Number = -_txtmc.width + 45;
			_txtmc.x = xoffset;

			if(_mc.name == "hits1"){
				_mc.x = _orgPos.x - xoffset;
			}

			if(_isShow){
				_mc.gotoAndPlay("update");
				return;
			}
			_isShow = true;
			_mc.gotoAndPlay("fadin");
		}

		public function hide():void{
			if(!_isShow) return;
			_isShow = false;
			_mc.gotoAndPlay("fadout");
		}


	}
}
