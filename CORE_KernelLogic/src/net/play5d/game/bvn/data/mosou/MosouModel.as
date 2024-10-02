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
				trace("load: ", partUrl);
				AssetManager.I.loadJSON(partUrl, loadNext, fail);
			}
			
			loadNext({remark: "first time!"});
		}
		
		private function initMapArea(area:MosouWorldMapAreaVO, d:Object):void{
			trace("initMapArea: ", d.id);
			
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