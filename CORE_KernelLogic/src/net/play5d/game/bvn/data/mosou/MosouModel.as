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

package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.ctrl.AssetManager;

	/**
	 * 无双数据（运行数据）
	 * @author K
	 *
	 */
	public class MosouModel
	{
		include '../../../../../../../include/_INCLUDE_.as';

		private static var _i:MosouModel;

		public static function get I():MosouModel{
			_i ||= new MosouModel();
			return _i;
		}

		private var _mapObj:Object = {};

		public var currentArea:MosouWorldMapAreaVO;
		public var currentMission:MosouMissionVO;

		public function MosouModel()
		{
		}

		public function getAllMap():Object{
			return _mapObj;
		}

		public function getMap(id:String):MosouWorldMapVO{
			return _mapObj[id];
		}

		public function getMapArea(mapId:String, areaId:String):MosouWorldMapAreaVO{
			var map:MosouWorldMapVO = _mapObj[mapId];
			if(!map) return null;
			return map.getArea(areaId);
		}

		public function loadMapData(back:Function, fail:Function):void{
			var mapId:String = "map1";
			var url:String = "config/mosou/" + mapId + "/" + mapId + ".json";
			AssetManager.I.loadJSON(url, function(o:Object):void{
				var map:MosouWorldMapVO = new MosouWorldMapVO();
				map.id = o.id;
				map.name = o.name;
				map.initWay(o.way);
				_mapObj[map.id] = map;
				loadAreas(map, o.parts, back, fail);

			}, fail);
		}

		private function loadAreas(map:MosouWorldMapVO, parts:Array, back:Function, fail:Function):void{
			var mapIds:Array = parts.concat();

			function loadNext(o:Object = null):void{
				if(!o){
					(fail != null) && fail();
					return;
				}

				if(o && o.id){
					var mv:MosouWorldMapAreaVO = map.getArea(o.id);
					if(mv) initMapArea(mv, o);
				}

				if(mapIds.length < 1){
					(back != null) && back();
					return;
				}

				var id:String = mapIds.shift();

				var partUrl:String = "config/mosou/"+map.id+"/"+id+".json";
				TraceLang('debug.trace.data.musou_model.load_area', partUrl);
				AssetManager.I.loadJSON(partUrl, loadNext, fail);
			}

			loadNext({remark: "first time!"});
		}

		private function initMapArea(area:MosouWorldMapAreaVO, d:Object):void{
			TraceLang('debug.trace.data.musou_model.init_map_area', d.id);

			area.id = d.id;
			area.name = d.name;

			area.missions = new Vector.<MosouMissionVO>();

			var miss:Array = d.missions;
			for(var j:int=0; j < miss.length; j++){
				var mv:MosouMissionVO = new MosouMissionVO();
				mv.initByJsonObject(miss[j]);
				area.missions.push(mv);
			}

		}

	}
}
