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

package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class KyoScrollList extends KyoTileList
	{
		private var _scrollType:int;
		private var _size:Point;
		public function KyoScrollList(displays:Array=null, size:Point = null , scrollType:int = 0)
		{
			_scrollType = scrollType;
			_size = size;
			var hrow:int = scrollType == 0 ? int.MAX_VALUE : 1;
			var vrow:int = scrollType == 1 ? int.MAX_VALUE : 1;

			scrollRect = new Rectangle(0,0,_size.x,_size.y);

			super(displays, hrow , vrow);
		}

		private var _rollSpeed:Number;
		private var _targetPos:Number;
		public function roll(speed:Number):void{
			_rollSpeed = speed;

			var addn:int = 0;

			switch(_scrollType){
				case 0:
					addn = Math.ceil(_size.x / (unitySize.x+gap.x));
					_targetPos = displays.length * (unitySize.x+gap.x);
					break;
				case 1:
					addn = Math.ceil(_size.y / (unitySize.y+gap.y));
					_targetPos = displays.length * (unitySize.y+gap.y);
					break;
			}

			if(addn >= displays.length) return;

			for(var i:int ; i < addn ; i++){
				displays.push(displays[i].clone());
			}

			update();

			addEventListener(Event.ENTER_FRAME,enterFrame);
		}

		private function enterFrame(e:Event):void{
			if(!_size) return;

			var srx:Number = scrollRect.x;
			var sry:Number = scrollRect.y;
			var sx:Number = 0 , sy:Number = 0;
			switch(_scrollType){
				case 0:
					sx = _rollSpeed;
					if(srx > _targetPos) srx = 0;
					if(srx < 0) srx = _targetPos;
					break;
				case 1:
					sy = _rollSpeed;
					if(sry > _targetPos) sry = 0;
					if(sry < 0) sry = _targetPos;
					break;
			}

			scrollRect = new Rectangle(srx + sx , sry + sy , _size.x , _size.y);
		}

	}
}
