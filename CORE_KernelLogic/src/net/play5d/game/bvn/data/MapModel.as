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

package net.play5d.game.bvn.data
{
import net.play5d.kyo.utils.KyoUtils;

public class MapModel
	{
		include "_INCLUDE_.as";

		private static var _i:MapModel;
		public static function get I():MapModel{
			_i ||= new MapModel();
			return _i;
		}

		private var _mapObj:Object;
		[ArrayElementType('net.play5d.game.bvn.data.MapVO')]
		private var _mapArray:Array;

		public function MapModel()
		{
		}

		public function getMap(id:String):MapVO{
			return _mapObj[id];
		}

		public function getMapBGM(id:String):BgmVO{
			var mv:MapVO = getMap(id);
			if(!mv || !mv.bgm) return null;

			var bv:BgmVO = new BgmVO();
			bv.id = 'map';
			bv.url = mv.bgm;
			bv.rate = 1;
			return bv;
		}

		public function getAllMaps():Array{
			return _mapArray;
		}

//		public function initByXML(xml:XML):void{
//			_mapObj = {};
//			_mapArray = [];
//
//			for each(var i:XML in xml.map){
//				var mv:MapVO = new MapVO();
//				mv.initByXML(i);
//				_mapObj[mv.id] = mv;
//				_mapArray.push(mv);
//			}
//
//		}

		public function initByObject(obj:Object):void {
			_mapObj = {};
			_mapArray = [];

			var mapObj:Object = obj['map'];
			for each(var i:Object in mapObj['data']) {
				var mapVOObj:Object = KyoUtils.cloneObject(i);
				mapVOObj['path'] = mapObj['path'];

				var mapVO:MapVO = new MapVO();
				mapVO.initByObject(mapVOObj);

				_mapObj[mapVO.id] = mapVO;
				_mapArray.push(mapVO);
			}
		}

	}
}
