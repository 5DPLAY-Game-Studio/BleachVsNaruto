package net.play5d.game.bvn.utils
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;

	public class MCUtils
	{
		public function MCUtils()
		{
		}
		
		public static function hasFrameLabel(mc:MovieClip , label:String):Boolean{
			var labels:Array = mc.currentLabels;
			for each(var i:FrameLabel in labels){
				if(i.name == label) return true;
			}
			return false;
		}
		
		/**
		 * 设置MC色相（-180 - 180） 
		 * @param d
		 * @param hue
		 * 
		 */
		public static function setHUE(d:DisplayObject, hue:Number = 0):void{
			if(hue == 0){
				d.filters = null;
			}else{
				var filter:ColorMatrixFilter = createHueFilter(hue);
				d.filters = [filter];
			}
		}
		
//		public static function stopMovieclips(mc:MovieClip):void{
//			try{
//				mc.stopAllMovieClips();
//			}catch(e:Error){
//				trace(e);
//				mc.stop();
//			}
//		}
		
		private static function createHueFilter(n:Number):ColorMatrixFilter
		{
			const p1:Number = Math.cos(n * Math.PI / 180);
			const p2:Number = Math.sin(n * Math.PI / 180);
			const p4:Number = 0.213;
			const p5:Number = 0.715;
			const p6:Number = 0.072;
			return new ColorMatrixFilter([p4 + p1 * (1 - p4) + p2 * (0 - p4), p5 + p1 * (0 - p5) + p2 * (0 - p5), p6 + p1 * (0 - p6) + p2 * (1 - p6), 0, 0, p4 + p1 * (0 - p4) + p2 * 0.143, p5 + p1 * (1 - p5) + p2 * 0.14, p6 + p1 * (0 - p6) + p2 * -0.283, 0, 0, p4 + p1 * (0 - p4) + p2 * (0 - (1 - p4)), p5 + p1 * (0 - p5) + p2 * p5, p6 + p1 * (1 - p6) + p2 * p6, 0, 0, 0, 0, 0, 1, 0]);
		}
		
	}
}