package net.play5d.kyo.utils
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class AJAX
	{
		public function AJAX()
		{
		}
		
		public static function post(url:String , data:URLVariables = null , back:Function = null):void{
			loadurl(url,data,URLRequestMethod.POST,back);
		}
		
		public static function get(url:String , data:URLVariables = null , back:Function = null):void{
			loadurl(url,data,URLRequestMethod.GET,back);
		}
		
		private static function loadurl(url:String , obj:Object , method:String ,back:Function):void{
			var rq:URLRequest = new URLRequest(url);
			rq.data = obj;
			rq.method = method;
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE,function():void{
				trace('url访问成功');
				if(back != null) back(l.data);
			});
			l.load(rq);
		}
		
		
	}
}