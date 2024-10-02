package net.play5d.kyo
{
	import flash.display.BitmapData;
	import flash.system.System;
	import flash.utils.Dictionary;

	public class KyoCacher
	{
		private static var _cacheObjs:Object = {};
		public static var amount:int;
		public static var maxMemory:int = 213377024;
		
		public static function cacheById(obj:*, id:String):void{
//			if(System.totalMemory > maxMemory){
//				clear();
//			}
			amount++;
			_cacheObjs[id] = obj;
		}
		
		public static function getById(id:String):*{
			var obj:* = _cacheObjs[id];
			if(!obj || obj == undefined){
				return null;
			}else{
				return obj;
			}
		}
		
		public static function clear():void{
			for each(var i:* in _cacheObjs){
				clearItem(i);
			}
			
			amount = 0;
			_cacheObjs = {};
		}
		
		private static function clearItem(i:*):void{
			if(i is BitmapData){
				(i as BitmapData).dispose();
			}
			if(i is Array){
				for each(var k:* in i){
					clearItem(k);
				}
			}
			i = null;
		}
		
		
	}
}