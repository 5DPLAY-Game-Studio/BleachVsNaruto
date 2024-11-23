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

package net.play5d.game.bvn.fighter.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.fighter.models.HitVO;

	public class McAreaCacher
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private var _idCache:Object = {};
		private var _frameCache:Object = {};

		public var name:String;

		public function McAreaCacher(name:String)
		{
			this.name = name;
//			trace('new McAreaCacher');
		}

		public function destory():void{
			_idCache = null;
			_frameCache = null;
		}

		/**
		 * 是否已定义区域
		 */
		public function areaFrameDefined(frame:int):Boolean{
//			trace('areaFrameDefined' , frame , _frameCache[frame]);
			return _frameCache[frame] !== undefined;
		}

		public function getAreaByFrame(frame:int):Object{
//			trace('getAreaByFrame' , frame , _frameCache[frame]);
			return _frameCache[frame];
		}

		public function cacheAreaByFrame(frame:int , area:Object):void{
			_frameCache[frame] = area;
//			trace('cacheAreaByFrame' , frame , _frameCache[frame]);
		}

		/**
		 * 根据ID取区域Rect
		 * @return {name,area};
		 */
		public function getAreaByDisplay(display:DisplayObject):Object{
			var cacheid:String = getDisplayCacheId(display);
			if(_idCache[cacheid]) return _idCache[cacheid];
			return null;
		}

		/**
		 * 根据显示对象缓存Rect
		 * @return {name,area};
		 */
		public function cacheAreaByDisplay(display:DisplayObject , area:Rectangle , customParam:Object = null):Object{
			var cacheid:String = getDisplayCacheId(display);

			var displayName:String = display.name;

			var cacheObj:Object = {};

			cacheObj.name = displayName;
			cacheObj.area = area;

			if(customParam){
				for(var i:String in customParam){
					cacheObj[i] = customParam[i];
				}
			}

//			if(displayName.indexOf("atm") != -1){
//				cacheObj.id = displayName.replace("atm","");
//			}

			_idCache[cacheid] = cacheObj;
			return cacheObj;
		}

		private function getDisplayCacheId(d:DisplayObject):String{
			return d.name + '_' + d.x + ',' + d.y + ',' + d.width + ',' + d.height + ',' + d.rotation;
		}

	}
}
