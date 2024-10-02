package net.play5d.kyo.display.bitmap
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 位图字体，使用Starling的位图字体格式 
	 */
	public class BitmapFont
	{
		/**
		 * 字与字之间的间距 
		 */
		public var charGap:Number = 0;
		/**
		 * 空格的间距 
		 */
		public var spaceGap:Number = 0;
		
		/**
		 * X偏移量 
		 */
		public var offsetX:Number = 0;
		/**
		 * Y偏移量 
		 */
		public var offsetY:Number = 0;
		
		private var _source:BitmapData; //源位图数据
		private var _fontCache:Object = {};
		
		private var _charWidth:int; //单字宽度
		private var _charHeight:int; //单字高度（取最大）
		private var _yOffsetMin:int = 999; //最小偏移Y
		
		public function BitmapFont(fontXML:XML , fontBitmap:BitmapData)
		{
			_source = fontBitmap;
			_charWidth = fontXML.info.@size;
			
			for each(var i:XML in fontXML.chars.char){
				var char:InsCharVO = new InsCharVO(i);
				if(_charHeight < char.height) _charHeight = char.height;
				if(_yOffsetMin > char.yoffset) _yOffsetMin = char.yoffset;
				_fontCache[char.id] = char;
			}
		}
		
		public function translate(str:String):BitmapData{
			
			var charWidth:Number = 0;
			var outputChars:Array = [];
			var i:int;
			var char:InsCharVO;
			for(i=0 ; i < str.length ; i++){
				var code:int = str.charCodeAt(i);
				
				if(code == 32 && spaceGap){
					charWidth += spaceGap;
					continue;
				}
				
				char = getChar(code);
				if(!char){
					if(code == 32) charWidth += _charWidth + charGap;
					continue;
				}
				
				char.x = charWidth;
				charWidth += char.width + charGap;
				outputChars.push(char);
			}
			
			if(charGap < 0) charWidth -= charGap;
			
			var output:BitmapData = new BitmapData(charWidth,_charHeight,true,0);
			
			for(i=0 ; i < outputChars.length ; i++){
				char = outputChars[i];
				
				var sourceRect:Rectangle = new Rectangle(
					char.sx,
					char.sy,
					char.width,
					char.height
				);
				
				var destPoint:Point = new Point(
					char.x + offsetX ,
					char.y + (char.yoffset-_yOffsetMin) + offsetY
				);
				
				output.copyPixels(_source,sourceRect,destPoint,null,null,true);
				
			}
			
			return output;
			
		}
		
		private function getChar(code:int):InsCharVO{
			var char:InsCharVO = _fontCache[code];
			if(char){
				return char.clone();
			}
			return null;
		}
		
	}
}

internal class InsCharVO{
	
	public var x:Number=0;
	public var y:Number=0;
	
	public var id:String;
	
	public var sx:int;
	public var sy:int;
	
	public var width:int;
	public var height:int;
	
	public var xoffset:int;
	public var yoffset:int;
	
	public var xadvance:int;
	
	private var _xml:XML;
	
	public function InsCharVO(xml:XML = null){
		_xml = xml;
		if(xml){
			id = xml.@id;
			sx = xml.@x;
			sy = xml.@y;
			width = xml.@width;
			height = xml.@height;
			xoffset = xml.@xoffset;
			yoffset = xml.@yoffset;
			xadvance = xml.@xadvance;
		}
	}
	
	public function clone():InsCharVO{
		return new InsCharVO(_xml);
	}
	
}