package net.play5d.kyo.display
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public class BMCNumber extends MCNumber
	{
		private var _insArray:Array;
		public function BMCNumber(mc:Object, number:uint, startFrame:int=1, mcWidth:Number=-1)
		{
			var mcc:Class;
			if(mc is Class) mcc = mc as Class;
			if(mc is Array) _insArray = mc as Array;
			super(mcc, number, startFrame, mcWidth);
		}
		
		protected override function createNum(i:int):DisplayObject{
			var bmc:BitmapMovieClip = new BitmapMovieClip(false);
			if(_insArray){
				bmc.insArray = _insArray;
			}else{
				var mc:MovieClip = new _mc();
				bmc.draw(mc);
			}
			bmc.gotoAndStop(startFrame + i);
			addChild(bmc);
			_mcs.push(bmc);
			return bmc;
		}
	}
}