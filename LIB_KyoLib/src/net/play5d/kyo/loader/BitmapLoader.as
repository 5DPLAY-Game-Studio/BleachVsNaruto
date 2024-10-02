package net.play5d.kyo.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BitmapLoader
	{
		public var bitmap:Bitmap;
		public var url:String;
		public function BitmapLoader()
		{
		}
		
		public function load(url:String , back:Function = null , fail:Function = null):void{
			this.url = url;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFail);
			loader.load(new URLRequest(url));
			
			function loadComplete(e:Event):void{
				bitmap = loader.content as Bitmap;
				
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loadFail);
				loader.unload();
				loader = null;
				
				if(back != null) back(bitmap);
			}
			
			function loadFail(e:IOErrorEvent):void{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loadFail);
				loader = null;
				if(fail != null) fail();
			}
			
		}
		
	}
}