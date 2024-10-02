package net.play5d.kyo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	public class BitmapOutput extends Bitmap
	{
		private var _source:DisplayObject;
		private var _width:int;
		private var _height:int;
		private var _transparent:Boolean;
		private var _fillColor:int;
		public function BitmapOutput(source:DisplayObject , width:int , height:int , transparent:Boolean = false , fillColor:int = 0 , pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
			_source = source;
			_width = width;
			_height = height;
			_transparent = transparent;
			_fillColor = fillColor;
		}

		public function render():void{
			bitmapData = new BitmapData(_width , _height , _transparent , _fillColor);
			var m:Matrix = new Matrix(_source.scaleX,0,0,_source.scaleY);
			bitmapData.draw(_source , m);
		}

		public function destory():void{
			_source = null;
			bitmapData.dispose();
			bitmapData = null;
		}
	}
}
