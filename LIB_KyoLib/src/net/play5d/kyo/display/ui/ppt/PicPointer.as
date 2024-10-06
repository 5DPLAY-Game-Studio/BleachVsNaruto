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

package net.play5d.kyo.display.ui.ppt
{
	import com.greensock.TweenLite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import net.play5d.kyo.display.ui.ppt.effect.BasePPTEffect;
	import net.play5d.kyo.display.ui.ppt.effect.PPTef_scrollH;

	/**
	 * 滚动图片幻灯
	 */
	public class PicPointer extends Sprite
	{
		private var _datas:Array;
		private var _loaders:Object;

		private var _curId:int = -1;
		public var size:Point;
		public var delay:Number;

		/**
		 * 移动方向（1：左右滚动，2：上下滚动）
		 */
//		public var direct:int = 2;
		private var _dragAble:Boolean;
		private var _picSprite:Sprite;
		private var _effect:BasePPTEffect;

		private var _loaderCtrl:PPTLoaderCtrl = new PPTLoaderCtrl();

		private var _infoTxt:TextField;

		public function set showInfo(v:Boolean):void{
			if(v){
				if(!_infoTxt){
					_infoTxt = new TextField();
					_infoTxt.textColor = 0xffffff;
					_infoTxt.mouseEnabled = false;
					_infoTxt.width = size.x;
					_infoTxt.height = size.y;
					_infoTxt.multiline = true;
					addChild(_infoTxt);
				}
			}else{
				if(_infoTxt){
					try{
						removeChild(_infoTxt);
					}catch(e:*){}
					_infoTxt = null;
				}
			}
		}

		public function infoMsg(v:String):void{
			if(_infoTxt) _infoTxt.text = v;
		}

		public function get curId():int{
			return _curId;
		}

		/**
		 * 是否能拖动
		 */
		public function get dragAble():Boolean{
			return _dragAble;
		}
		public function set dragAble(v:Boolean):void{
			_dragAble = v;
			if(v) _effect.initDrag();
		}
		public function PicPointer(size:Point, delay:Number = 1, effect:BasePPTEffect = null)
		{
			this.size = size;
			this.delay = delay;

			scrollRect = new Rectangle(0,0,size.x,size.y);

			_effect = effect;
			_effect ||= new PPTef_scrollH();

			_picSprite = new Sprite();
			addChild(_picSprite);

			_picSprite.graphics.beginFill(0,0);
			_picSprite.graphics.drawRect(0,0,size.x,size.y);
			_picSprite.graphics.endFill();
		}

		private function newPicLoader(size:Point):PicLoader{
			var pl:PicLoader = new PicLoader(size);
			_picSprite.addChild(pl);
			pl.visible = false;
			return pl;
		}

		/**
		 *  初始化
		 * @param data 图片数据
		 */
		public function initlize(data:Array):void{
			_effect.initlize(this,_picSprite);

			setData(data);
//			loadNext();
			_curId = 0;
			resetLoaders();
			addEventListener(MouseEvent.MOUSE_UP,onClick);
			initTimer();

			dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START,_curId));
		}

		public function update(data:Array):void{
			destory();
			setData(data);
			_curId = 0;
			initTimer();
			resetLoaders();
			dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START,_curId));
		}

		private function setData(v:Array):void{
			_loaders = {};
			var needLoads:Array = [];
			for(var i:int ; i < v.length ; i++){
				var url:String = v[i];
				var pl:PicLoader = new PicLoader(size,url);
				pl.id = i;
				_loaders[pl.id] = pl;
				needLoads.push(pl);
			}
			_datas = v;

			_loaderCtrl.addEventListener(PicPointerEvent.LOAD_PROCESS,onLoadProcess);
			_loaderCtrl.addEventListener(PicPointerEvent.LOAD_COMPLETE,onLoadComplete);
			_loaderCtrl.loadQueue(needLoads);
		}

		private function onLoadProcess(e:PicPointerEvent):void{
			var per:Number = Number(e.data);
			var percentStr:String = int(per * 100) + '%';
			infoMsg("正在加载资源："+percentStr+" ("+_loaderCtrl.curIndex+"/"+_loaderCtrl.totalIndex+")");

			var allProcess:Number = (_loaderCtrl.curIndex - 1 + per) / _loaderCtrl.totalIndex;
			this.dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_PROCESS,allProcess));
		}

		private function onLoadComplete(e:PicPointerEvent):void{
			showInfo = false;
			this.dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_COMPLETE));
		}

		private function initTimer():void{
			if(_datas.length > 1){
				if(!_timer){
					_timer = new Timer(delay * 1000 , 1);
					_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
				}
			}else{
				if(_timer){
					_timer.stop();
					_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
					_timer = null;
				}
			}

			resume();
		}

		private function onClick(e:MouseEvent):void{
			if(!_effect.canClick()) return;
			dispatchEvent(new PicPointerEvent(PicPointerEvent.MOUSE_UP,_curId));
		}

		public function destory():void{
			_curId = -1;

			if(_loaders){
				for each(var p:PicLoader in _loaders){
					try{
						_picSprite.removeChild(p);
					}catch(e:Error){}
					p.destory();
				}
				_loaders = null;
			}

		}

		private function fixid(id:int):int{
			if(id > _datas.length - 1) id = 0;
			if(id < 0) id = _datas.length - 1;
			return id;
		}

		private function tweenFinish():void{
			resetLoaders();
			resume();
			dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_FINISH,_curId));
		}

		private function resetLoaders():void{
			if(!_loaders) return;

			var curLoader:PicLoader = _loaders[fixid(_curId)];
			var nextLoader:PicLoader = _loaders[fixid(_curId+1)];
			var prevLoader:PicLoader = _loaders[fixid(_curId-1)];

			_effect.setPics(curLoader , nextLoader , prevLoader);

			while(_picSprite.numChildren > 0){
				_picSprite.removeChildAt(0);
			}

			_picSprite.addChild(curLoader);
			_picSprite.addChild(nextLoader);
			_picSprite.addChild(prevLoader);
		}

		public function pause():void{
			if(_timer) _timer.stop();
		}
		public function resume():void{
			if(_timer){
				_timer.reset();
				_timer.start();
			}
		}

		private var _timer:Timer;
		private function onTimer(e:TimerEvent):void{
//			if(_curLoader.finish())
			toNext();
		}

		public function toNext():void{
			pause();
			_curId = fixid(_curId+1);
			dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START,_curId));
			_effect.tweenNext(tweenFinish);
		}

		public function toPrev():void{
			pause();
			_curId = fixid(_curId-1);
			dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START,_curId));
			_effect.tweenPrev(tweenFinish);
		}

		public function jump(id:int):void{
			if(id == _curId) return;

			_curId = fixid(id-1);
			resetLoaders();

			toNext();
		}


	}
}
