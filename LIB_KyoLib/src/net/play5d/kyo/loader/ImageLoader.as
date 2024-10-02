package net.play5d.kyo.loader
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;

	public class ImageLoader extends Loader
	{
		/**
		 * 忽略错误
		 */
		public var mergeError:Boolean = true;
		public static var traceError:Boolean = true;
		public var loadFail:Boolean;
		private var _url:String;
		private var _size:Point;

		public function get url():String{
			return _url;
		}

		public function ImageLoader(url:String = null, size:Point = null, back:Function = null, fail:Function = null)
		{
			super();
			_size = size;
			if(url) loadImage(url,back,fail);
		}

		private var _smooth:Boolean;

		public function get smooth():Boolean{
			return _smooth;
		}

		public function set smooth(v:Boolean):void{
			_smooth = v;
			if(content){
				var bp:Bitmap = content as Bitmap;
				if(bp) bp.smoothing = v;
			}
		}

		private var _back:Function;
		private var _fail:Function;
		public function loadImage(url:String , back:Function = null , fail:Function = null):void{
			unloadAndDispose();
			try{
				this['unloadAndStop'](true);
			}catch(e:Error){}

			_url = url;
			loadFail = false;
			_back = back;
			_fail = fail;

			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);

			load(new URLRequest(url));
		}

		public function unloadAndDispose():void{
			if(content){
				var bp:Bitmap = content as Bitmap;
				unload();
				if(bp) bp.bitmapData.dispose();
			}
		}

		public function reload():void{
			loadImage(_url);
		}

		private function onComplete(e:Event):void{
			if(_size){
				if(_size.x == 0){
					height = _size.y;
					scaleX = scaleY;
				}else if(_size.y == 0){
					width = _size.x;
					scaleY = scaleX;
				}else{
					width = _size.x;
					height = _size.y;
				}
			}

			smooth = _smooth;

			dispatchEvent(e);
			if(_back != null){
				_back(this);
				_back = null;
			}
			removeListener();
		}

		private function onIOError(e:IOErrorEvent):void{
			if(traceError) trace('load error :' , _url);
			loadFail = true;
			if(!mergeError) dispatchEvent(e);
			if(_fail != null){
				_fail(this);
				_fail = null;
			}
			removeListener();
		}

		private function removeListener():void{
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
			contentLoaderInfo.removeEventListener(Event.COMPLETE,onComplete);
		}
	}
}
