package net.play5d.kyo.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import net.play5d.kyo.utils.vo.KyoWeaterVO;

	public class KyoWeather
	{
		private static var _weatherxml:XML;
		private static var yweather:Namespace = new Namespace("http://xml.weather.yahoo.com/ns/rss/1.0");
		
		public static function loadWeather(cityCode:int , back:Function = null , error:Function = null):void{
			var url:String = "http://weather.yahooapis.com/forecastrss" +
				"?w=" + cityCode + "&u=c";
			var ul:URLLoader = new URLLoader(new URLRequest(url));
			ul.addEventListener(Event.COMPLETE,success);
			ul.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			
			function success(e:Event):void{
				removeListeners();
				_weatherxml = new XML(ul.data);
				var codeToday:String = _weatherxml.channel.item.yweather::forecast[0].@code;
				if(back != null)back();
				ul = null;
			}
			function errorHandler(e:Event):void{
				removeListeners();
				if(error != null)error();
				ul = null;
			}
			
			function removeListeners():void{
				ul.removeEventListener(Event.COMPLETE,success);
				ul.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
				ul.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			}
		}
		
		private static var _todayWeather:KyoWeaterVO;
		public static function get todayWeather():KyoWeaterVO{
			if(!_weatherxml) return null;
			if(!_todayWeather){
				_todayWeather = new KyoWeaterVO();
				var x:XML = _weatherxml.channel.item.yweather::forecast[0];
				_todayWeather.low = x.@low;
				_todayWeather.high = x.@high;
				_todayWeather.code = x.@code;
			}
			return _todayWeather;
		}
		
		private static var _tomorrowWeather:KyoWeaterVO;
		public static function get tomorrowWeather():KyoWeaterVO{
			if(!_weatherxml) return null;
			if(!_tomorrowWeather){
				_tomorrowWeather = new KyoWeaterVO();
				var x:XML = _weatherxml.channel.item.yweather::forecast[1];
				_tomorrowWeather.low = x.@low;
				_tomorrowWeather.high = x.@high;
				_tomorrowWeather.code = x.@code;
			}
			return _tomorrowWeather;
		}
		
	}
}