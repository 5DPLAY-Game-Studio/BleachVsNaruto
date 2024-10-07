/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
