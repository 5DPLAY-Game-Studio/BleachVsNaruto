package net.play5d.game.bvn.utils
{
	import net.play5d.kyo.utils.WebUtils;

	public class URL
	{
		public function URL()
		{
		}
		
		public static var MARK:String = 'bvn';
		
		public static const WEBSITE:String = "http://www.1212321.com/index/";
		public static const BBS:String = "http://bbs.1212321.com/";
		public static const DOWNLOAD:String = "http://www.1212321.com/index/";
		public static const DOWNLOAD_ANDROID:String = "http://1212321.com/index/game/phone/a48b52f9-6b6a-4448-91d2-d666ff93edd7";
		
		
		public static function go(url:String , isAddMark:Boolean = true):void{
			if(isAddMark){
				var newurl:String = markURL(url);
				WebUtils.getURL(newurl);
			}else{
				WebUtils.getURL(url);
			}
		}
		
		public static function markURL(url:String):String{
			var addMark:String = url.indexOf('?') == -1 ? '?' : '&';
			var newurl:String = url + addMark + MARK;
			return newurl;
		}
		
		public static function website(...params):void{
			go(WEBSITE);
		}
		
		public static function buyJoystick(...params):void{
			go('http://bbs.1212321.com/forum.php?mod=viewthread&tid=110' , false);
		}
		
		public static function bbs(...params):void{
			go(BBS);
		}
		
		public static function supportUS(...params):void{
			go('https://www.patreon.com/bleachvsnaruto' , false);
		}
		
		public static function download():void{
			go(DOWNLOAD , false);
		}
		
		public static function download_android(...params):void{
			go(DOWNLOAD_ANDROID);
		}
		
	}
}