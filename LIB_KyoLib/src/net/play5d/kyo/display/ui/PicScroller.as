package net.play5d.kyo.display.ui
{
	import com.greensock.TweenLite;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * 滚动图片幻灯
	 */
	public class PicScroller extends Sprite
	{
		private var _datas:Array;
		private var _loader:Loader;
		private var _curId:int = -1;
		public var size:Point;
		public var speed:Number;
		public var delay:Number;

		/**
		 * 移动方向（1：从左向右，2：从右向左，3：从上向下，4：从下向上）
		 */
		public var direct:int = 4;
		public var lockWidth:Boolean = true;
		public var lockHeight:Boolean = false;
		/**
		 * 是否允许在移动中拖动
		 */
		public var movingTouch:Boolean = false;

		public var showNear:Boolean = true;

		private var _direct:int;

		private var _dragAble:Boolean;

		private var _sp:Sprite;

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
			if(v){
				removeEventListener(MouseEvent.MOUSE_DOWN,dragDown);
				addEventListener(MouseEvent.MOUSE_DOWN,dragDown);
			}
		}
		public function PicScroller(size:Point, speed:Number = 1, delay:Number = 1)
		{
			this.speed = speed;
			this.size = size;
			this.delay = delay;

			scrollRect = new Rectangle(0,0,size.x,size.y);

			_sp = new Sprite();
			addChild(_sp);
		}

		public function initlize(data:Array):void{
			_datas = data;
			_direct = direct;
			loadNext();

			addEventListener(MouseEvent.MOUSE_UP,onClick);
		}

		public function update(data:Array):void{
			destory();
			_datas = data;
			_direct = direct;
			loadNext();
		}

		private function onClick(e:MouseEvent):void{
			if(_draging) return;
			if(_downP){
				var jl:Number = Math.abs(mouseX-_downP.x) + Math.abs(mouseY-_downP.y);
				if(jl > 20) return;
			}
			dispatchEvent(new PicScrollEvent(PicScrollEvent.MOUSE_UP,_curId));
		}

		public function destory():void{
			_curId = -1;
			pause();
			if(_loader){
				_loader.unload();
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				_loader = null;
			}
		}

		private function loadNext():void{
			_curId++;
			_curId = fixid(_curId);

			if(_loader){
				_loader.unload();
			}else{
				_loader = new Loader();
			}

			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			_loader.load(new URLRequest(_datas[_curId]));
			_sp.addChild(_loader);
		}

		private function fixid(id:int):int{
			if(id > _datas.length - 1) id = 0;
			if(id < 0) id = _datas.length - 1;
			return id;
		}

		private function loadComplete(e:Event):void{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			formatPic(_loader);

			if(showNear){
				loadNear();
			}else{
				startMove();
			}
		}

		private var _nearLoader:Loader;
		private function loadNear():void{
			_nearLoader = new Loader();
			_nearLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadNearComplete);

			var nid:int = fixid(_curId + 1);
			_nearLoader.load(new URLRequest(_datas[nid]));

			switch(_direct){
				case 1:
					break;
				case 2:
					break;
				case 3:
					break;
				case 4:
					_nearLoader.x = 0;
					_nearLoader.y = _loader.height;
					break;
			}
			_sp.addChild(_nearLoader);
		}
		private function loadNearComplete(e:Event):void{
			_nearLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadNearComplete);
			formatPic(_nearLoader);
			startMove();
		}
		private function formatPic(l:Loader):void{
			if(lockWidth && lockHeight){
				l.width = size.x;
				l.height = size.y;
				return;
			}

			if(lockWidth){
				l.width = size.x;
				l.scaleY = _loader.scaleX;
			}

			if(lockHeight){
				l.height = size.y;
				l.scaleX = _loader.scaleY;
			}
		}

		private function startMove():void{
			dispatchEvent(new PicScrollEvent(PicScrollEvent.CHANGE,_curId));

			initStartPos();

			resume();
			_reached = false;

		}
		private function pause():void{
			removeEventListener(Event.ENTER_FRAME,moving);
			_moving = false;
			if(_timer) _timer.stop();
		}
		private var _moving:Boolean;
		private function resume():void{
			removeEventListener(Event.ENTER_FRAME,moving);
			addEventListener(Event.ENTER_FRAME,moving);

			_moving = true;

			if(_timer){
				_timer.reset();
				_timer.start();
			}
		}
		private function moving(e:Event):void{
			move();
			if(checkOver()){
				pause();
				loadNext();
				return;
			}
			checkReach();
		}

		private function getSpd():Number{
			var spd:Number;
			var czp:Point = new Point();
			switch(_direct){
				case 1:
				case 2:
					czp.x = _sp.x;
					czp.y = _loader.width - size.x;
					break;
				case 3:
				case 4:
					czp.x = _sp.y;
					czp.y = _loader.height - size.y;
					break;
			}
			var jj:Number = Math.abs(czp.x) - Math.abs(czp.y);
			var jj2:Number = Math.abs(jj);

			if(czp.x > 0){
				spd = czp.x * 0.1;
			}else if(jj > 0){
				spd = jj2 * 0.1;
				if(jj2 > _loader.height/1.6) spd = 1;
			}else{
				spd = speed;
			}

			trace(jj2);

			if(spd < speed) spd = speed;
			return spd;
		}

		private function move():void{
			var spd:Number = getSpd();

			switch(_direct){
				case 1:
					_sp.x += spd;
					break;
				case 2:
					_sp.x -= spd;
					break;
				case 3:
					_sp.y += spd;
					break;
				case 4:
					_sp.y -= spd;
					break;
			}
		}

		private function initStartPos():void{
			if(showNear){
				switch(_direct){
					case 1:
					case 2:
						_sp.x = 0;
						break;
					case 3:
					case 4:
						_sp.y = 0;
						break;
				}
				return;
			}

			switch(_direct){
				case 1:
					_sp.x = -_loader.width;
					break;
				case 2:
					_sp.x = size.x;
					break;
				case 3:
					_sp.y = -_loader.height;
					break;
				case 4:
					_sp.y = size.y;
					break;
			}
		}

		private function checkOver():Boolean{
			switch(_direct){
				case 1:
					return _sp.x > size.x;
					break;
				case 2:
					return _sp.x < -_loader.width;
					break;
				case 3:
					return _sp.y > size.y;
					break;
				case 4:
					return _sp.y < -_loader.height;
					break;
			}
			return false;
		}

		private var _reached:Boolean;
		private function checkReach():void{
			if(_reached) return;
			var b:Boolean;
			switch(_direct){
				case 1:
					b = _sp.x >= 0;
					break;
				case 2:
					b = _sp.x <= -(_loader.width - size.x);
					break;
				case 3:
					b = _sp.y >= 0;
					break;
				case 4:
					b = _sp.y <= -(_loader.height - size.y);
					break;
			}
			if(b) reach();
		}

		private var _timer:Timer;
		private var _tweening:Boolean;
		private function reach():void{
			pause();
			var k:String;
			var v:Number;
			switch(_direct){
				case 1:
					k = 'x';
					v = 0;
					break;
				case 2:
					k = 'x';
					v = -(_loader.width - size.x);
					break;
				case 3:
					k = 'y';
					v = 0;
					break;
				case 4:
					k = 'y';
					v = -(_loader.height - size.y);
					break;
			}
			if(Math.abs(_sp[k] - v) > 10){
				_tweening = true;
				var o:Object = {};
				o[k] = v;
				o['onComplete'] = function():void{
					_tweening = false;
				}
				TweenLite.to(_sp,0.5,o);
			}

			_reached = true;
			dispatchEvent(new PicScrollEvent(PicScrollEvent.CHANGE_COMPLETE,_curId));
			newTimer();

			_direct = direct;
		}
		private function reachComplete(e:TimerEvent):void{
			removeTimer();
			resume();
		}
		private function newTimer():void{
			removeTimer();
			_timer = new Timer(delay * 1000 , 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,reachComplete);
			_timer.start();
		}
		private function removeTimer():void{
			if(_timer){
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,reachComplete);
				_timer = null;
			}
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		private var _downP:Point;
		private var _draging:Boolean;
		private function dragDown(e:MouseEvent):void{
			_downP = new Point(mouseX-_sp.x , mouseY-_sp.y);

			if(!movingTouch && _moving) return;
			if(_tweening) return;

			if(stage){
				stage.addEventListener(MouseEvent.MOUSE_UP,dragUp);
			}else{
				addEventListener(MouseEvent.MOUSE_UP,dragUp);
			}

			removeEventListener(Event.ENTER_FRAME,draging);
			addEventListener(Event.ENTER_FRAME,draging);

			pause();
		}

		private function draging(e:Event):void{
			switch(direct){
				case 1:
				case 2:
					_draging ||= Math.abs(mouseX - _downP.x) > 10;
					if(_draging) _sp.x = mouseX - _downP.x;
					break;
				case 3:
				case 4:
					_draging ||= Math.abs(mouseY - _downP.y) > 10;
					if(_draging) _sp.y = mouseY - _downP.y;
					break;
			}
		}

		private var _prev:Boolean;
		private function dragUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP,dragUp);
			removeEventListener(MouseEvent.MOUSE_UP,dragUp);

			removeEventListener(Event.ENTER_FRAME,draging);

			if(!_draging) return;
			_draging = false;

			switch(_direct){
				case 1:
					if(_sp.x < -_loader.width / 4){
						_direct = 2;
						_curId -= 2;
						_reached = true;
					}
					break;
				case 2:
					if(_sp.x > _loader.width / 4){
						_direct = 1;
						_curId -= 2;
						_reached = true;
					}
					break;
				case 3:
					if(_sp.y < -_loader.height / 4){
						_direct = 4;
						_curId -= 2;
						_reached = true;
					}
					break;
				case 4:
					if(_sp.y > _loader.height / 4){
						_direct = 3;
						_curId -= 2;
						_reached = true;
					}
					break;
			}

			resume();
		}

	}
}
