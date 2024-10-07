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

package net.play5d.kyo
{
	import flash.display.BitmapData;
	import flash.system.System;
	import flash.utils.Dictionary;

	public class KyoCacher
	{
		private static var _cacheObjs:Object = {};
		public static var amount:int;
		public static var maxMemory:int = 213377024;

		public static function cacheById(obj:*, id:String):void{
//			if(System.totalMemory > maxMemory){
//				clear();
//			}
			amount++;
			_cacheObjs[id] = obj;
		}

		public static function getById(id:String):*{
			var obj:* = _cacheObjs[id];
			if(!obj || obj == undefined){
				return null;
			}else{
				return obj;
			}
		}

		public static function clear():void{
			for each(var i:* in _cacheObjs){
				clearItem(i);
			}

			amount = 0;
			_cacheObjs = {};
		}

		private static function clearItem(i:*):void{
			if(i is BitmapData){
				(i as BitmapData).dispose();
			}
			if(i is Array){
				for each(var k:* in i){
					clearItem(k);
				}
			}
			i = null;
		}


	}
}
