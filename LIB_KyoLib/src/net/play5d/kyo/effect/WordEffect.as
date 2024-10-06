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

	import flash.text.TextField;

	/**
	 * 文字效果类
	 * @author kyo
	 */
	public class WordEffect
	{
		/**
		 * 一个字一个字的出现
		 * @param txt
		 * @param gapTime 间隔（秒）
		 */
		public static function showOneByOne(txt:TextField,gapTime:Number = 0.03,finish:Function = null):void{
			var str:String = txt.text;
			var len:int = str.length;
			txt.text = '';
			for(var i:int ; i < len ; i++){
				var f:Function;
				if(finish != null){
					if(i == len - 1){
						f = finish;
					}
				}
				TweenLite.delayedCall(i * gapTime,function(ci:int):void{
					txt.appendText(str.charAt(ci));
					if(f != null) f();
				},[i]);
			}
		}
	}
}
