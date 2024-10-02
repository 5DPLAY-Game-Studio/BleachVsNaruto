package net.play5d.game.bvn.utils
{
	import flash.display.Bitmap;

	public class EmbedAssetUtils
	{

		[Embed(source='/../assets/alipay.png')]
		private static var alipayPNG:Class;

		[Embed(source='/../assets/weixin.png')]
		private static var weixinPNG:Class;

		[Embed(source='/../assets/patreon.png')]
		private static var patreonPNG:Class;

		[Embed(source='/../assets/android.png')]
		private static var androidPNG:Class;


		private static var _alipay:Bitmap;
		private static var _weixin:Bitmap;
		private static var _patreon:Bitmap;
		private static var _android:Bitmap;

		public function EmbedAssetUtils()
		{
		}

		public static function getAndroid():Bitmap{
			if(!_android){
				_android = new androidPNG();
				_android.smoothing = true;
			}
			return _android;
		}

		public static function getAlipay():Bitmap{
			if(!_alipay){
				_alipay = new alipayPNG();
				_alipay.smoothing = true;
			}
			return _alipay;
		}

		public static function getWeixin():Bitmap{
			if(!_weixin){
				_weixin = new weixinPNG();
				_weixin.smoothing = true;
			}
			return _weixin;
		}

		public static function getPatreon():Bitmap{
			if(!_patreon){
				_patreon = new patreonPNG();
				_patreon.smoothing = true;
			}
			return _patreon;
		}

	}
}
