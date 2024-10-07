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
	import flash.display.Stage;
	import flash.events.TouchEvent;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.kyo.utils.ArrayMap;

	public class TouchUtils
	{

		private static var _i:TouchUtils;

		public static function get I():TouchUtils{
			_i ||= new TouchUtils();
			return _i;
		}

		private var _oneFingerPoint:TouchPoint;
		private var _oneFingerDraging:Boolean;

		private var _callBackMap:Dictionary = new Dictionary();

		private var _stage:Stage;

		private var _checkDragDis:Number = 0;


		private var _callTwoBackMap:Dictionary = new Dictionary();
		private var _twoFingerMap:ArrayMap = new ArrayMap();
		private var _twoFingerDraging:Boolean;
		private var _twoFingerDelta:Number = 0;

		public function TouchUtils()
		{
		}

		public function init(stage:Stage):void{
			_stage = stage;
			_checkDragDis = cm2pixel(0.1);
		}

		public function isDraging():Boolean{
			return _oneFingerDraging || _twoFingerDraging;
		}

		// 单点触摸 =======================================================================================================================

		public function listenOneFinger(d:DisplayObject, back:Function, dragX:Boolean = true, dragY:Boolean = true):void{
			_callBackMap[d] = new TouchCallBack(back, dragX, dragY);

			d.removeEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
			d.addEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
		}

		public function unlistenOneFinger(d:DisplayObject):void{
			delete _callBackMap[d];
			d.removeEventListener(TouchEvent.TOUCH_BEGIN, oneFingerHandler);
		}

		private function oneFingerHandler(e:TouchEvent):void{
			if(_oneFingerPoint) return;

			var d:DisplayObject = e.currentTarget as DisplayObject;

			if(_callBackMap[d]) (_callBackMap[d] as TouchCallBack).callBegin(e.stageX, e.stageY);

			_oneFingerPoint = new TouchPoint(e.touchPointID);

			_oneFingerPoint.stageX = e.stageX;
			_oneFingerPoint.stageY = e.stageY;

			_oneFingerPoint.target = d;

			_oneFingerDraging = false;

			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
			_stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

			_stage.addEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
			_stage.addEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

		}

		private function stageOneFingerHandler(e:TouchEvent):void{
			if(e.touchPointID != _oneFingerPoint.touchId) return;

			if(!_oneFingerPoint.target || !_callBackMap[_oneFingerPoint.target]){
				_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

				_oneFingerPoint = null;
				_oneFingerDraging = false;
				return;
			}

			var tc:TouchCallBack = _callBackMap[_oneFingerPoint.target];

			if(e.type == TouchEvent.TOUCH_END){
				_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageOneFingerHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_END, stageOneFingerHandler);

				tc.callEnd(e.stageX, e.stageY);

				setTimeout(function():void{
					_oneFingerPoint = null;
					_oneFingerDraging = false;
				}, 300);

				return;
			}

			var deltaX:Number = e.stageX - _oneFingerPoint.stageX;
			var deltaY:Number = e.stageY - _oneFingerPoint.stageY;

			if(!_oneFingerDraging){
				_oneFingerDraging = tc.getDragDistance(deltaX, deltaY) > _checkDragDis;
				return;
			}

			_oneFingerPoint.stageX = e.stageX;
			_oneFingerPoint.stageY = e.stageY;

			tc.callMoving(deltaX / GameConfig.GAME_SCALE.x, deltaY / GameConfig.GAME_SCALE.y);

		}


		// 两点触摸 =======================================================================================================================

		public function listenTwoFinger(d:DisplayObject, back:Function):void{
			_callTwoBackMap[d] = new TouchTwoCallBack(back);

			d.removeEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
			d.addEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
		}

		public function unlistenTwoFinger(d:DisplayObject):void{
			delete _callTwoBackMap[d];
			d.removeEventListener(TouchEvent.TOUCH_BEGIN, twoFingerHandler);
		}

		private function twoFingerHandler(e:TouchEvent):void{
			if(_twoFingerMap.length > 2) return;

			var d:DisplayObject = e.currentTarget as DisplayObject;
			var tp:TouchPoint = new TouchPoint(e.touchPointID);

			tp.stageX = e.stageX;
			tp.stageY = e.stageY;
			tp.target = d;

			_twoFingerMap.push(tp.touchId, tp);

			if(_twoFingerMap.length == 2){
				_twoFingerDraging = false;
				_twoFingerDelta = 0;

				_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

				_stage.addEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
				_stage.addEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

				if(_callTwoBackMap[d]) (_callTwoBackMap[d] as TouchTwoCallBack).callBegin();
			}

		}

		private function stageTwoFingerHandler(e:TouchEvent):void{
			if(_twoFingerMap.length != 2) return;

			var p1:TouchPoint = _twoFingerMap.getItemByIndex(0);
			var p2:TouchPoint = _twoFingerMap.getItemByIndex(1);

			if(!p1.target || !_callTwoBackMap[p1]){
				_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

				_twoFingerMap = new ArrayMap();

				return;
			}

			var tc:TouchTwoCallBack = _twoFingerMap[p1.target];

			if(e.type == TouchEvent.TOUCH_END){
				_twoFingerMap.removeItemById(e.touchPointID);

				if(_twoFingerMap.length < 1){
					_stage.removeEventListener(TouchEvent.TOUCH_MOVE, stageTwoFingerHandler);
					_stage.removeEventListener(TouchEvent.TOUCH_END, stageTwoFingerHandler);

					tc.callEnd();

					setTimeout(function():void{
						_twoFingerMap = new ArrayMap();
						_twoFingerDraging = false;
						_twoFingerDelta = 0;
					}, 300);
				}

				return;
			}

			var delta:Number = Math.abs(p1.stageX - p2.stageX) + Math.abs(p1.stageY - p2.stageY);
			if(!_twoFingerDraging){
				_twoFingerDraging = delta > _checkDragDis;
			}

			_twoFingerDelta = delta - _twoFingerDelta;
			tc.callMoving(_twoFingerDelta);
		}


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		private function cm2pixel(cm:Number):Number{
			var dpi:Number = Capabilities.screenDPI;
			return (cm * dpi) / 2.54;
		}

	}
}






/******************************************************************************************************
 *
 *   内部私有类
 *
 *
 * ****************************************************************************************************/


import flash.display.DisplayObject;
import flash.geom.Point;

import net.play5d.game.bvn.utils.TouchMoveEvent;

internal class TouchPoint{
	public var touchId:int;

	public var stageX:Number = 0;
	public var stageY:Number = 0;

	public var target:DisplayObject = null;

	public function TouchPoint(touchId:int){
		this.touchId = touchId;
	}

}

internal class TouchCallBack{
	private var callback:Function;

	private var dragX:Boolean;
	private var dragY:Boolean;

	private var _startX:Number;
	private var _startY:Number;

	public function TouchCallBack(back:Function, dragX:Boolean = true, dragY:Boolean = true){
		this.callback = back;
		this.dragX = dragX;
		this.dragY = dragY;
	}

	public function callBegin(startX:Number, startY:Number):void{
		_startX = startX;
		_startY = startY;

		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_BEGIN);
		event.startX = startX;
		event.startY = startY;

		callback(event);
	}

	public function callEnd(endX:Number, endY:Number):void{
		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_END);
		event.startX = _startX;
		event.startY = _startY;
		event.endX = endX;
		event.endY = endY;

		event.distanceX = event.endX - event.startX;
		event.distanceY = event.endY - event.startY;

		callback(event);
	}

	public function callMoving(deltaX:Number, deltaY:Number):void{
		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_MOVE);
		event.startX = _startX;
		event.startY = _startY;

		event.deltaX = deltaX;
		event.deltaY = deltaY;

		callback(event);
	}

	public function getDragDistance(deltaX:Number, deltaY:Number):Number{

		if(dragX && dragY){
			return Math.abs(deltaX) + Math.abs(deltaY);
		}

		if(dragX){
			return Math.abs(deltaX);
		}

		if(deltaY){
			return Math.abs(deltaY);
		}

		return 0;
	}

}


internal class TouchTwoCallBack{
	private var callback:Function;


	public function TouchTwoCallBack(back:Function){
		this.callback = back;
	}

	public function callBegin():void{

		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_BEGIN);
		callback(event);
	}

	public function callEnd():void{
		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_END);
		callback(event);
	}

	public function callMoving(delta:Number):void{
		if(callback == null) return;

		var event:TouchMoveEvent = new TouchMoveEvent(TouchMoveEvent.TOUCH_MOVE);
		event.delta = delta;
		callback(event);
	}

	public function getDragDistance(pointA:Point, pointB:Point):Number{

		return 0;
	}

}
