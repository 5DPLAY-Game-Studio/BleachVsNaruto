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

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 2D镜头
	 * @modify 2011.1.26
	 * @author kyo
	 */
	public class GameCamera
	{
		/**
		 * 大于1时，缓动开始生效，值越大，缓动越慢
		 */
		public var tweenSpd:int;
		public var stageSize:Point;

		/**
		 * 是否跟随X
		 */
		public var focusX:Boolean = true;
		/**
		 * 是否跟随Y
		 */
		public var focusY:Boolean;

		/**
		 * 焦点位置偏移X
		 */
		public var offsetX:Number = 0;
		/**
		 * 焦点位置偏移Y
		 */
		public var offsetY:Number = 0;


		/**
		 * 自动缩放，跟随多个对象的位置，只有一个焦点时无效
		 */
		public var autoZoom:Boolean = false;
		/**
		 * 最小比例
		 */
		public var autoZoomMin:Number = 1;
		/**
		 * 最大比例
		 */
		public var autoZoomMax:Number = 3;

//		public var x:Number = 0;
//		public var y:Number = 0;

		private var _zoom:Number = 1;
		private var _noTweenRect:Rectangle;

		private var _stage:DisplayObject;
		private var _stageBounds:Rectangle;
		private var _rect:Rectangle;
		private var _focus:Array;
		private var _point:Point;
		private var _stageScale:Number = 1;
//		private var _scrollRect:Rectangle = new Rectangle();
		/**
		 * fixForderRect
		 */
		private var _fbR:Rectangle;
		private var _foffsetX:Number = 0;
		private var _foffsetY:Number = 0;
		private var _screenSize:Point;


		public function getScreenRect(withTween:Boolean = false):Rectangle{
			return withTween ? _rect : _noTweenRect;
		}

		/**
		 * 2D摄像机 构造函数  ! 注意：需要调用render()函数才能生效
		 * @param stage 场景
		 * @param screenSize 显示屏幕宽和高
		 * @param stageSize 场景大小，为NULL则取stage的width,height
		 * @param fixBorder 是否修正场景超出屏幕边缘时的情况，默认不修正
		 */
		public function GameCamera(stage:DisplayObject , screenSize:Point , stageSize:Point = null , fixBorder:Boolean = false)
		{
			_stage = stage;
			_rect = new Rectangle(0,0,screenSize.x,screenSize.y);
			_noTweenRect = new Rectangle(0,0,screenSize.x,screenSize.y);

			_screenSize = new Point(screenSize.x,screenSize.y);
			if(fixBorder) _fbR = new Rectangle();

			this.stageSize = stageSize;
			if(!this.stageSize) setStageSizeFromDisplay(_stage);

			setStageBounds();
		}

		public function updateNow():void{
			var oldTweenSpd:Number = tweenSpd;
			tweenSpd = 0;
			render();
			tweenSpd = oldTweenSpd;
		}

		public function setStageBounds(rect:Rectangle = null):void{
			if(!rect){
				_stageBounds = _stage.getBounds(_stage);
			}else{
				_stageBounds = rect;
			}
			setZoom(_zoom);
		}

		public function setStageSizeFromDisplay(d:DisplayObject):void{
			stageSize = new Point(d.width / d.scaleX + _stageBounds.x, d.height / d.scaleY + _stageBounds.y);
		}

		public function getZoom(withTween:Boolean = false):Number
		{
			return withTween ? _stageScale : _zoom;
//			return _stageScale;
		}

		public function setZoom(value:Number):void
		{
			_zoom = value;

			_noTweenRect.width = _screenSize.x / _zoom;
			_noTweenRect.height = _screenSize.y / _zoom;

			_foffsetX = _screenSize.x / 2 / _zoom;
			_foffsetY = _screenSize.y / 2 / _zoom;

			//边界
			if(_fbR){
				_fbR.x = _stageBounds.x * _zoom;
				_fbR.y = _stageBounds.y * _zoom;
				_fbR.width = _stageBounds.width - _screenSize.x / _zoom;
				_fbR.height = _stageBounds.height - _screenSize.y / _zoom;
			}
		}

		public function focus(focusArr:Array , notween:Boolean = false):void{
			_focus = focusArr;

			_point = _focus.length > 1 ? new Point() : null;

			if(notween){
				var tweenBK:int = tweenSpd;
				tweenSpd = 0;
				render();
				tweenSpd = tweenBK;
			}
		}

		public function move(x:Number , y:Number):void{
			_focus = null;
			_point = new Point(x,y);
		}

		public function moveCenter():void{
			_focus = null;
			_point = new Point(stageSize.x / 2 , stageSize.y / 2);
		}

		public function render():void{
			if(!_focus && !_point) return;

			if(_focus.length > 1){
				renderTwo(_focus[0] , _focus[_focus.length-1]);
			}

			if(focusX) renderX();
			if(focusY) renderY();
			if(_stageScale != _zoom) renderZoom();

			//应用设置
			applySet();

		}

		private function applySet():void{
			_stage.scrollRect = _rect;
//			_stage.x = -_rect.x;
//			_stage.y = -_rect.y;
			_stage.scaleX = _stage.scaleY = _stageScale;
		}

		/**
		 * 计算两者的中间位置
		 */
		private function renderTwo(a:DisplayObject , b:DisplayObject):void{
			var distanceX:Number = 0;
			var distanceY:Number = 0;

			if(focusX){
				var l:DisplayObject,r:DisplayObject;
				if(a.x < b.x){
					l = a;
					r = b;
				}else{
					l = b;
					r = a;
				}
				distanceX = r.x - l.x;
				_point.x = l.x + distanceX / 2;
			}
			if(focusY){
				var u:DisplayObject,d:DisplayObject;
				if(a.y < b.y){
					u = a;
					d = b;
				}else{
					u = b;
					d = a;
				}
				distanceY = d.y - u.y;
				_point.y = u.y + distanceY / 2;
			}

			if(autoZoom){
				var zoomX:Number = _zoom;
				var zoomY:Number = _zoom;

				if(focusX) zoomX = _screenSize.x / distanceX * 0.8;
				if(focusY) zoomY = _screenSize.y / distanceY * 0.8;

				var zoom:Number = Math.min(zoomX , zoomY);
				renderAutoZoom(zoom);
			}
		}

		/**
		 * 自动缩放
		 */
		private function renderAutoZoom(zoom:Number):void{
			if(zoom < autoZoomMin) zoom = autoZoomMin;
			if(zoom > autoZoomMax) zoom = autoZoomMax;
			setZoom(zoom);
		}

		private function renderX():void{
			var fx:Number;
			fx = _point ? _point.x : _focus[0].x;
			fx -= _foffsetX + offsetX;
//			fx *= _zoom;
			setX(fx);
		}

		private function renderY():void{
			var fy:Number;
			fy = _point ? _point.y : _focus[0].y;
			fy -= _foffsetY + offsetY;
//			fy *= _zoom;
			setY(fy);
		}

		public function setX(v:Number):void{

			if(_fbR){
				if(v < _fbR.x) v = _fbR.x;
				if(v > _fbR.width) v = _fbR.width;
			}

			_noTweenRect.x = v;

			if(tweenSpd > 1){
				_rect.x += (v - _rect.x) / tweenSpd;
			}else{
				_rect.x = v;
			}
		}

		public function setY(v:Number):void{

			if(_fbR){
				if(v < _fbR.y) v = _fbR.y;
				if(v > _fbR.height) v = _fbR.height;
			}

			_noTweenRect.y = v;

			if(tweenSpd > 1){
				_rect.y += (v - _rect.y) / tweenSpd;
			}else{
				_rect.y = v;
			}
		}

		private function renderZoom():void{
			if(_zoom <= 0) throw new Error('zoom 不能 <= 0 !');
			if(tweenSpd > 1){
				_stageScale += (_zoom - _stageScale) / tweenSpd;
			}else{
				_stageScale = _zoom;
			}
			_rect.width = (_screenSize.x / _stageScale + 1) >> 0;
			_rect.height = (_screenSize.y / _stageScale + 1) >> 0;
		}

	}
}
