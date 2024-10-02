package net.play5d.kyo.display.ui.ppt
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class SwfLoader extends Sprite
	{
		private var _size:Point;
		private var _swfWidth:Number = 0;
		private var _swfHeight:Number = 0;
		private var _loader:Loader;


		public function SwfLoader(url:String = null, size:Point = null, back:Function = null, fail:Function = null, process:Function = null)
		{
			super();

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_loader.addEventListener(FaultEvent.FAULT, fatalErrorHandler);
			addChild(_loader);

			_size = size;
			this.scrollRect = new Rectangle(0,0,_size.x,_size.y);
			if(url != null) loadSwf(url,back,fail,process);
		}

		private var _loadBack:Function;
		private var _failBack:Function;
		private var _process:Function;
		public function loadSwf(url:String , back:Function = null , fail:Function = null , process:Function = null):void{
			_loadBack = back;
			_failBack = fail;
			_process = process;

			_loader.load(new URLRequest(url));
		}

		private function IOErrorHandler(event:IOErrorEvent):void
		{
			trace("SWFLoader:IOErrorHandler : " + event);
			if(_failBack != null){
				_failBack();
				_failBack = null;
			}
		}

		private function fatalErrorHandler(event:FaultEvent):void
		{
			trace("SWFLoader:fatalErrorHandler : " + event);
			if(_failBack != null){
				_failBack();
				_failBack = null;
			}
		}

		private function onProcess(e:ProgressEvent):void{
			if(_process != null){
				var per:Number = e.bytesLoaded / e.bytesTotal;
				_process(this,per);
			}
		}


		private function loadSwfComplete(e:Event):void{
			var loaderinfo:LoaderInfo = (e.currentTarget as LoaderInfo);
			_swfWidth = loaderinfo.width;
			_swfHeight = loaderinfo.height;

			if(_size){
				_loader.scaleX = _size.x / _swfWidth;
				_loader.scaleY = _size.y / _swfHeight;
			}

			if(_loadBack != null){
				_loadBack();
				_loadBack = null;
			}
		}

		public function unload():void{
			if(_loader){
				_loader.unloadAndStop(true);
			}
		}

	}
}
