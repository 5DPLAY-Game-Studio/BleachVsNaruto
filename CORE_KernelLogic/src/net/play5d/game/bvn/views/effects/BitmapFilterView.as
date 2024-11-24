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
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.data.TeamVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoUtils;

	public class BitmapFilterView implements IGameSprite
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _bitmap:Bitmap;
		public var target:BaseGameSprite;
		private var _filter:BitmapFilter;
		private var _filterOffset:Point;
		private var _isDestoryed:Boolean;
		private var _bitmapFrame:int;
		private var _targetDisplay:DisplayObject;
		private var _targetBounds:Rectangle;
		private var _targetFighter:FighterMain;
		private var _isActive:Boolean;

		public function BitmapFilterView(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null)
		{
			_bitmap = new Bitmap(null, "auto", false);
			this.target = target;

			if(target is FighterMain){
				_targetFighter = target as FighterMain;
			}

			_targetDisplay = target.getDisplay();
			_filter = filter;
			_filterOffset = filterOffset;
		}

		public function getActive():Boolean{
			return _isActive;
		}

		public function setActive(v:Boolean):void{
			_isActive = v;
		}

		public function setVolume(v:Number):void{
		}

		public function update(filter:BitmapFilter, filterOffset:Point = null):void{
			_filter = filter;
			_filterOffset = filterOffset;
		}

		public function renderAnimate():void{
//			if(!target) return;

//			if(_bitmap.bitmapData){
//				_bitmap.bitmapData.dispose();
//				_bitmap.bitmapData = null;
//			}
//			_bitmap.bitmapData = KyoUtils.drawBitmapFilter(target.getDisplay(), _filter, true, _filterOffset);
//
//			var display:DisplayObject = target.getDisplay();
//
//			_targetBounds = display.getBounds(display);
		}

		public function render():void{
			if(!target || !_targetDisplay) return;
			if(_isDestoryed) return;
			renderBitmapData();


			_bitmap.scaleX = _targetDisplay.scaleX;
			_bitmap.scaleY = _targetDisplay.scaleY;

			if(target.direct > 0){
				_bitmap.x = _targetDisplay.x - _filterOffset.x + _targetBounds.x;
			}else{
				_bitmap.x = _targetDisplay.x + _filterOffset.x - _targetBounds.x;
			}

			_bitmap.y = _targetDisplay.y - _filterOffset.y + _targetBounds.y;
		}

		private function renderBitmapData():void{
			if(_targetFighter){
				var curFrame:int = _targetFighter.getMC().getCurrentFrameCount();
				if(curFrame == _bitmapFrame) return;
				_bitmapFrame = curFrame;
			}

			if(_bitmap.bitmapData){
				_bitmap.bitmapData.dispose();
				_bitmap.bitmapData = null;
			}
			_bitmap.bitmapData = KyoUtils.drawBitmapFilter(_targetDisplay, _filter, true, _filterOffset);

			_targetBounds = _targetDisplay.getBounds(_targetDisplay);
		}

		public function isDestoryed():Boolean{
			return _isDestoryed;
		}


		public function getDisplay():DisplayObject{
			return _bitmap;
		}

		public function get direct():int{
			return target.direct;
		}
		public function set direct(value:int):void{

		}

		public function get x():Number{
			return _bitmap.x;
		}
		public function set x(v:Number):void{
			_bitmap.x = v;
		}

		public function get y():Number{
			return _bitmap.y;
		}
		public function set y(v:Number):void{
			_bitmap.y = v;
		}

		public function get team():TeamVO{
			return null;
		}
		public function set team(v:TeamVO):void{

		}

		public function hit(hitvo:HitVO , target:IGameSprite):void{

		}
		public function beHit(hitvo:HitVO , hitRect:Rectangle = null):void{

		}

		public function getArea():Rectangle{
			return null;
		}

		public function getBodyArea():Rectangle{
			return null;
		}

		public function getCurrentHits():Array{
			return null;
		}

		public function allowCrossMapXY():Boolean{
			return true;
		}
		public function allowCrossMapBottom():Boolean{
			return true;
		}

		public function getIsTouchSide():Boolean{
			return false;
		}
		public function setIsTouchSide(v:Boolean):void{

		}

		public function setSpeedRate(v:Number):void{

		}

		public function destory(dispose:Boolean = true):void{
			if(dispose){
				if(_bitmap.bitmapData){
					_bitmap.bitmapData.dispose();
					_bitmap.bitmapData = null;
				}
				_isDestoryed = true;
				this.target = null;
				_filter = null;
				_filterOffset = null;
				_targetFighter = null;
				_targetBounds = null;
				_targetDisplay = null;
			}
		}

	}
}
