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
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class IphoneIconList extends Sprite
	{
		public var curPage:int;
		public var totalPage:int;
		public var perpage:int;
		public var _thisX:Number = 0;
		public var hrow:int = 4;
		public var touchSize:Point;
		public var enalbed:Boolean = true;
		/**
		 * 翻页的滑动速度
		 */
		public var touchPow:Number = 30;
		/**
		 * 翻页的滑动距离(比例)
		 */
		public var touchDis:Number = 0.3;

		private var _unitSize:Point;
		private var _oldthisX:Number = 0;
		private var _tweenX:Number = 0;
		private var _lists:Array;
		private var _gap:Point = new Point();

		public function get gapx():Number{
			return _gap.x;
		}
		public function get gapy():Number{
			return _gap.y;
		}

		public var gap:Point;
		public var listPos:Point;

		public function IphoneIconList(touchSize:Point, unitSize:Point = null, perpage:int = 16, hrow:int = 4)
		{
			this.touchSize = touchSize;
			_unitSize = unitSize;
			this.perpage = perpage;
			this.hrow = hrow;
		}

		public function anyoneDoFunction(fun:String , ...params):void{
			for each(var d:DisplayObject in displays){
				if(d == null) continue;
				var f:Function = d[fun];
				f.apply(null,params);
			}
		}

		public function destory():void{
			this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,downHanlder);
			if(stage) stage.removeEventListener(MouseEvent.MOUSE_UP,upHandler);

			for each(var i:KyoTileList in _lists){
				i.anyoneDoFunction('destory');
			}

			removeLists();

			if(_tween){
				_tween.pause();
				_tween.kill();
				_tween = null;
			}
		}

		private function removeLists():void{
			for each(var i:KyoTileList in _lists){
				try{
					removeChild(i);
				}catch(e:Error){
					trace(e);
				}
			}
			_lists = null;
		}

		public function get length():uint{
			return _displays.length;
		}

		private var _displays:Array;
		public function get displays():Array{
			return _displays;
		}

		public function setDisplay(v:Array):void{
			_displays = v;
			update();
		}
		public function addDisplay(d:DisplayObject):void{
			_displays ||= [];
			_displays.push(d);
			if(!_lists){
				update();
				return;
			}
			var list:KyoTileList = _lists[_lists.length-1];
			if(!list || list.displays.length >= perpage){
				var cp:int = curPage;
				update();
				if(curPage != cp) goPage(cp,false);
				return;
			}
			list.addDisplay(d);
		}

		public function removeDisplay(d:DisplayObject , updateNow:Boolean = true):void{
			var id:int = displays.indexOf(d);
			if(id == -1) return;
			removeDisplayAt(id,updateNow);
		}

		public function removeDisplayAt(id:int , updateNow:Boolean = true):void{
			displays.splice(id,1);
			if(updateNow) update();
		}

		public function update():void{
			_gap = new Point();

			var vrow:int = Math.ceil(perpage / hrow);

			var fristP:Point = new Point();

			if(!gap){
				var l1:Number = _unitSize.x;
				var l:Number = touchSize.x - l1;
				_gap.x = (l-_unitSize.x) / (hrow-1) - _unitSize.x;
				fristP.x = l1/2;

				var h1:Number = _unitSize.y;
				var h2:Number = touchSize.y - h1;
				_gap.y = (h2-_unitSize.y) / (vrow-1) - _unitSize.y;
				fristP.y = h1/2;
			}else{
				_gap.x = gap.x;
				_gap.y = gap.y;
			}

			if(listPos) fristP = listPos.clone();

			removeLists();
			_lists = [];
			updateScrollRect();

			curPage = 1;
			totalPage = Math.ceil(_displays.length / perpage);


			for(var i:int = curPage ; i <= totalPage ; i++){
				var list:KyoTileList = createList(i);
				list.x = fristP.x + (i - 1) * touchSize.x;
				list.y = fristP.y;
				addChild(list);
				_lists.push(list);
			}

			this.graphics.clear();
			this.graphics.beginFill(0 , 0);
			this.graphics.drawRect(0 , 0 , touchSize.x * totalPage , touchSize.y*1.1);
			this.graphics.endFill();

			_tweenX = 0;
			resumeComplete();
		}

		private function updateScrollRect():void{
			this.scrollRect = new Rectangle(-_thisX,0,touchSize.x,touchSize.y*1.1);
		}

		private function createList(page:int):KyoTileList{
			var ppp:int = page * perpage;
			var ss:int = ppp - perpage;
			if(ss < 0) ss = 0;
			var ee:int = Math.min((ss + perpage) , _displays.length);
			var pps:Array = _displays.slice(ss,ee);

			var vr:int = perpage / hrow;

			var list:KyoTileList = new KyoTileList(pps,hrow,vr);
			list.lockSize = true;
			list.unitySize = _unitSize;
			list.gap = _gap;
			list.update();
			return list;
		}
		private var _listEnable:Boolean = true;
		private function set listsEnable(v:Boolean):void{
			if(_listEnable == v) return;
			_listEnable = v;
			for each(var i:KyoTileList in _lists){
				i.mouseEnabled = i.mouseChildren = v;
				for each(var n:DisplayObject in i.displays){
					if(n is IiphoneBtn) (n as IiphoneBtn).onDrag();
				}
			}
		}

		private var _oldX:Number;
		private function downHanlder(e:Event):void{
			if(!enalbed) return;

			this.removeEventListener(MouseEvent.MOUSE_DOWN,downHanlder);

			if(stage == null) return;

			_oldX = stage.mouseX;
			_oldthisX = _thisX;
			_curMouseX = stage.mouseX;

			if(!this.hasEventListener(Event.ENTER_FRAME))
				this.addEventListener(Event.ENTER_FRAME,onEnterFrame);

			stage.removeEventListener(MouseEvent.MOUSE_UP,upHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,upHandler);
		}
		private function upHandler(e:Event):void{
			this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);

			resume();

			var stg:Stage = e.currentTarget as Stage;
			if(stg)	stg.removeEventListener(MouseEvent.MOUSE_UP,upHandler);
			if(stage) stage.removeEventListener(MouseEvent.MOUSE_UP,upHandler);
		}

		private function resumeComplete():void{
			_thisX = _tweenX;
			_oldthisX = 0;
			updateScrollRect();
			this.addEventListener(MouseEvent.MOUSE_DOWN,downHanlder);
			listsEnable = true;
		}
		private var _mouseSpd:Number = 0;
		private var _curMouseX:Number = -1;
		private function onEnterFrame(e:Event):void{
			if(stage == null) return;

			_mouseSpd = stage.mouseX - _curMouseX;
			_curMouseX = stage.mouseX;

			var msx:Number = stage.mouseX;
			var pp:int = 1;
			if(msx > _oldX){
				if(curPage <= 1) pp = 2;
			}else{
				if(curPage >= totalPage) pp = 2;
			}
			_thisX = (msx - _oldX) / pp + _oldthisX;
			if(Math.abs(msx - _oldX) > 5) listsEnable = false;
			updateScrollRect();
		}

		private var _tween:TweenLite;
		private function resume():void{
			if(Math.abs(_mouseSpd) > touchPow){

				if(_mouseSpd > 0){
					if(prevPage()) return;
				}else{
					if(nextPage()) return;
				}

			}else{

				if(Math.abs((_thisX - _oldthisX)) > touchSize.x * touchDis){
					if(_thisX > _oldthisX){
						if(prevPage()) return;
					}else{
						if(nextPage()) return;
					}
				}

			}

			_tweenX = _oldthisX;
			_tween = TweenLite.to(this,.5,{_thisX:_tweenX,onComplete:resumeComplete,onUpdate:updateScrollRect});
		}
		public function nextPage():Boolean{
			return goPage(curPage + 1);
		}

		public function prevPage():Boolean{
			return goPage(curPage - 1);
		}

		public function goPage(p:int , tween:Boolean = true):Boolean{
			if(p < 1) return false;
			if(p > totalPage) return false;
			if(curPage == p) return false;

			this.removeEventListener(MouseEvent.MOUSE_DOWN,downHanlder);

			_tweenX += (curPage - p) * touchSize.x;
			if(tween){
				_tween = TweenLite.to(this,.5,{_thisX:_tweenX,onComplete:resumeComplete,onUpdate:updateScrollRect});
			}else{
				_thisX = _tweenX;
				resumeComplete();
			}

			curPage = p;
			dispatchEvent(new IphoneIconListEvent(IphoneIconListEvent.PAGE_CHANGE));

			return true;
		}

	}
}
