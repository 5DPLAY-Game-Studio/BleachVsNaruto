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

package net.play5d.kyo.effect.bitmapeffect
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.*;
	import flash.net.URLRequest;
	public class WaterWaveEffect extends Sprite
	{
		public var strongth:Number = 1;
		private var mouseDown:Boolean = false;
		private var result:BitmapData,result2:BitmapData,source:BitmapData,buffer:BitmapData,output:BitmapData,surface:BitmapData;
		private var bounds:Rectangle;
		private var origin:Point;
		private var matrix:Matrix,matrix2:Matrix;
		private var wave:ConvolutionFilter;
		private var damp:ColorTransform;
		private var water:DisplacementMapFilter;
		//
		private var imgW:Number;
		private var imgH:Number;

		private var size:int;

		public function WaterWaveEffect(img:BitmapData, scale:int = 1)
		{
			surface = img;

			imgW = img.width;
			imgH = img.height;
			size = scale;

			buildwave ();
		}

		public function destory():void{
			result.dispose();
			result2.dispose();
			source.dispose();
			buffer.dispose();
			surface.dispose();
			output.dispose();

			result = null;
			result2 = null;
			source = null;
			buffer = null;
			surface = null;
			output = null;

			wave = null;
			damp = null;
			water = null;
		}

		private function buildwave ():void {
			result = new BitmapData(imgW, imgH, false, 128);
			result2 = new BitmapData(imgW, imgH, false, 128);
			source = new BitmapData(imgW, imgH, false, 128);
			buffer = new BitmapData(imgW, imgH, false, 128);
			output = new BitmapData(imgW, imgH, false, 128);
			bounds = new Rectangle(0, 0, imgW, imgH);
			origin = new Point();

			matrix = new Matrix();
			matrix2 = new Matrix();
			matrix2.a = matrix2.d=2;

			wave = new ConvolutionFilter(3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1], 9, 0);
			damp = new ColorTransform(0, 0, 9.960937E-001, 1, 0, 0, 2, 0);
			water = new DisplacementMapFilter(result2, origin, 4, 4, 28, 28);
			var _bg:Sprite = new Sprite();
			addChild (_bg);
			_bg.graphics.beginFill (0xFFFFFF,0);
			_bg.graphics.drawRect (0,0,imgW,imgH);
			_bg.graphics.endFill ();

			var b:Bitmap = new Bitmap(output);
			b.scaleX = b.scaleY = size;
			addChild (b);

			render();
		}

		/**
		 *  运行
		 * @param points 包含坐标(Point)的数组
		 */
		public function render(points:Array = null):void {
			if(points){
				for each(var p:Point in points){
					var _x:Number = p.x / 1.5 / size;
					var _y:Number = p.y / 1.5 / size;
					source.setPixel (_x+strongth, _y, 16777215);
					source.setPixel (_x-strongth, _y, 16777215);
					source.setPixel (_x, _y+strongth, 16777215);
					source.setPixel (_x, _y-strongth, 16777215);
					source.setPixel (_x, _y, 16777215);
				}
			}

//			if(mousex != -1 && mousey != -1){
//				var _x:Number = mousex / 2 / size;
//				var _y:Number = mousey / 2 / size;
//				source.setPixel (_x+1, _y, 16777215);
//				source.setPixel (_x-1, _y, 16777215);
//				source.setPixel (_x, _y+1, 16777215);
//				source.setPixel (_x, _y-1, 16777215);
//				source.setPixel (_x, _y, 16777215);
//			}

			result.applyFilter (source, bounds, origin, wave);

			result.draw (result, matrix, null, BlendMode.ADD);
			result.draw (buffer, matrix, null, BlendMode.DIFFERENCE);
			result.draw (result, matrix, damp);
			result2.draw (result, matrix2, null, null, null, true);
			output.applyFilter (surface, new Rectangle(0, 0, imgW, imgH), origin, water);
			buffer = source;
			source = result.clone();
		}

	}
}
