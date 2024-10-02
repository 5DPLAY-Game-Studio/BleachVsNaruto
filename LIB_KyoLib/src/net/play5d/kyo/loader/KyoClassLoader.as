package net.play5d.kyo.loader
{
	import com.greensock.loading.LoaderMax;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class KyoClassLoader extends EventDispatcher
	{
		private var _classes:Object = {};
		private var _urls:Array;
		private var _defaultId:String;
		private var _loadedAmount:int;
		private var _loadLength:int;
		private var _directory:Dictionary = new Dictionary();
		public function KyoClassLoader()
		{
		}
		
		public function getClass(className:String,swf:String = null):Class{
			swf ||= _defaultId;
			var app:ApplicationDomain = _classes[swf];
			if(!app){
				throw new Error(swf+'未加载!');
				return null;
			}
			try{
				return app.getDefinition(className) as Class;
			}catch(e:Error){
				throw new Error('在 '+swf+' 中找不到 '+className+' 的定义!');
				trace('KyoClassLoader ::',e);
			}
			return null;
		}
		
		public function get loadedAmount():int{
			return _loadedAmount;
		}
		
		private var _loading:Boolean;
		public function load(url:Object):void{
			if(_loading) throw new Error('不可以在没完成加载时继续调用此方法!');
			
			if(url is String){
				_urls = [url];
			}
			if(url is Array){
				_urls = url as Array;
			}
			_loadLength = _urls.length;
			_loadedAmount = 0;
			loadNext();
			
			_loading = true;
		}
		
		public function addSwf(id:String , swf:Loader):void{
			_classes[id] = swf.contentLoaderInfo.applicationDomain;
			try{
				swf.unloadAndStop(true);
			}catch(e:Error){
				swf.unload();
			}
		}
		
		private function loadNext():Boolean{
			if(_urls.length < 1) return false;
			_loadedAmount++;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadError);
			
			var url:String = _urls.shift();
			loader.load(new URLRequest(url));
			_directory[loader] = url;
			
			return true;
		}
		
		private function removeLoader(loader:Loader):void{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loadError);
			try{
				loader.unloadAndStop(true);
			}catch(e:Error){
				loader.unload();
			}
			loader = null;
		}
		
		private function loadComplete(e:Event):void{
			var loaderinfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var loader:Loader = loaderinfo.loader;
			var id:String = _directory[loader];
			_defaultId ||= id;
			_classes[id] = loaderinfo.applicationDomain;
			removeLoader(loader);
			
			checkComplete();
		}
		
		private function loadProgress(e:ProgressEvent):void{
//			var m:int = (_loadedAmount / _loadLength) * 100;
//			var s:int = (e.bytesLoaded / e.bytesTotal) * m;
//			var h:int = 100;
			dispatchEvent(e);
		}
		
		private function loadError(e:IOErrorEvent):void{
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			var id:String;
			if(loader && loader.loaderInfo) id = loader.loaderInfo.loaderURL;
			
			trace('loadError',id);
			dispatchEvent(e);
			
			checkComplete();
		}
		
		private function checkComplete():void{
			if(loadNext() == false){
				_loading = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
	}
}