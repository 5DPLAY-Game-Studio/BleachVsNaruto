package net.play5d.kyo.loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class SWFLoader extends Loader
	{
		public var headInfo:SwfHeaderInfo;
		
		public function SWFLoader(url:String , back:Function = null)
		{
			loadSwf(url,back);
		}
		
		public function loadSwf(url:String , back:Function , fail:Function = null):void{
			loadHead(url,function():void{
				loadFlash(url,back);
			},fail);
		}
		
		private function loadHead(url:String , back:Function , fail:Function):void{
			KyoURLoader.load(url,ulcom,fail,{dataFormat:URLLoaderDataFormat.BINARY});
			
			function ulcom(b:ByteArray):void{
				if(!b){
					if(fail != null) fail();
					return;
				}
				headInfo = new SwfHeaderInfo(b);
				if(back != null) back();
			}
			
		}
		
		
		private function loadFlash(url:String,back:Function):void{
			contentLoaderInfo.addEventListener(Event.COMPLETE,loadCom);
			load(new URLRequest(url));
			
			function loadCom(e:Event):void{
				contentLoaderInfo.removeEventListener(Event.COMPLETE,loadCom);
				if(back != null) back();
			}
		}
		
	}
}