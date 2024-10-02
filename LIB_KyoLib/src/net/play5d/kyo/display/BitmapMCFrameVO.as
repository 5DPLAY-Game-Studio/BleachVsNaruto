package net.play5d.kyo.display
{
	import flash.display.BitmapData;

	public class BitmapMCFrameVO
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var bd:BitmapData;
		public var frameLabel:String;
		public function BitmapMCFrameVO()
		{
		}
		
		public function destory():void{
			if(bd){
				bd.dispose();
				bd = null;
			}
		}
	}
}