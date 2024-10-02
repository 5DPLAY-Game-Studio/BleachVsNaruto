package net.play5d.kyo.display.bitmap
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	/**
	 * 位图字体文本，基于BitmapFont
	 */
	public class BitmapFontText extends Bitmap
	{
		private var _font:BitmapFont;
		private var _text:String;
		private var _orgBitmapData:BitmapData;
		
		public function BitmapFontText(font:BitmapFont)
		{
			super(null, "auto", true);
			_font = font;
		}
		
		public function get text():String{
			return _text;
		}
		
		public function set text(v:String):void{
			_text = v;
			bitmapData = _font.translate(v);
			smoothing = true;
			width = bitmapData.width;
		}
		
		public function colorTransform(ct:ColorTransform):void{
			if(ct == null){
				if(_orgBitmapData){
					bitmapData.dispose();
					bitmapData = _orgBitmapData.clone();
				}
				return;
			}
			
			if(!_orgBitmapData) _orgBitmapData = bitmapData.clone();
			bitmapData.colorTransform(new Rectangle(0,0,bitmapData.width,bitmapData.height),ct);
		}
		
		public function dispose():void{
			if(_orgBitmapData){
				_orgBitmapData.dispose();
				_orgBitmapData = null;
			}
			bitmapData.dispose();
		}
		
	}
}