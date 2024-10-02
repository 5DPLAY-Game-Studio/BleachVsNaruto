package net.play5d.kyo.effect
{
	import flash.geom.ColorTransform;

	public class GhostShadowColorTransform
	{
		public function GhostShadowColorTransform()
		{
		}
		
		private static var _red:ColorTransform;
		public static function get red():ColorTransform{
			if(!_red){
				_red = new ColorTransform();
				_red.redOffset = 255;
			}
			return _red;
		}
		
		private static var _blue:ColorTransform;
		public static function get blue():ColorTransform{
			if(!_blue){
				_blue = new ColorTransform();
				_blue.blueOffset = 255;
			}
			return _blue;
		}
	}
}