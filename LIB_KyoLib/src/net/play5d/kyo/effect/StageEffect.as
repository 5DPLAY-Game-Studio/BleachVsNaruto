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

package net.play5d.kyo.effect
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	import net.play5d.kyo.utils.KyoUtils;

	public class StageEffect
	{
		private static var _i:StageEffect;
		public static function get I():StageEffect{
			_i ||= new StageEffect();
			return _i;
		}
		public var stage:DisplayObject;
		private var _tweening:Boolean;

		public function StageEffect()
		{
		}

		public function shine(duration:Number = 1 , color:uint = 0xffffff , alpha:Number = 0.5):void{
			TweenPlugin.activate([ColorTransformPlugin]);
			stage.transform.colorTransform = new ColorTransform();
			TweenLite.from(stage,duration,{colorTransform:{tint:color,tintAmount:alpha}});
		}

		private var _shakeBack:Function;
		public function shake(x:uint , y:uint , back:Function=null , gapFrame:int = 1):void{
			var iii:int = 1;
			var n:int;
			stage.x = stage.y = 0;

			doBack();
			_shakeBack = back;

			stage.removeEventListener(Event.ENTER_FRAME , onEnterFrame);
			stage.addEventListener(Event.ENTER_FRAME , onEnterFrame);

			function doBack():void{
				if(_shakeBack != null){
					_shakeBack();
					_shakeBack = null;
				}
			}

			function onEnterFrame(e:Event):void{
				n++;
				if(n % gapFrame != 0) return;

				stage.x = x * iii;
				stage.y = y * iii;

				iii *= -1;

				if(n % 2 == 0){
					if(x > 0) x--;
					if(y > 0) y--;
				}

				if(x <= 0 && y <= 0){
					stage.removeEventListener(Event.ENTER_FRAME , onEnterFrame);
					stage.x = 0;
					stage.y = 0;
					doBack();
				}
			}
		}

		public function applyColorTransform(ct:ColorTransform):void{
			stage.transform.colorTransform = ct;
		}

		public function bigShadow():void{
			var pt:DisplayObjectContainer = stage.parent;
			if(!pt) return;
			var bp:Bitmap = KyoUtils.drawDisplay(stage,false);
			pt.addChild(bp);
			bp.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			function onEnterFrame(e:Event):void{
				bp.x -= 6.5;
				bp.y -= 6.5;
				bp.scaleX += 0.04;
				bp.scaleY += 0.04;
				bp.alpha -= 0.1;
				if(bp.alpha <= 0){
					bp.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
					pt.removeChild(bp);
					bp.bitmapData.dispose();
					bp = null;
				}
			}
		}

	}
}
