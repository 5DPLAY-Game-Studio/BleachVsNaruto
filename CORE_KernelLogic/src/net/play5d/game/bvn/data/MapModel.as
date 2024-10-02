package net.play5d.game.bvn.data
{
	public class MapModel
	{
		private static var _i:MapModel;
		public static function get I():MapModel{
			_i ||= new MapModel();
			return _i;
		}
		
		private var _mapObj:Object;
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
		
		public function initByXML(xml:XML):void{
			_mapObj = {};
			_mapArray = [];
			
			for each(var i:XML in xml.map){
				var mv:MapVO = new MapVO();
				mv.initByXML(i);
				_mapObj[mv.id] = mv;
				_mapArray.push(mv);
			}
			
		}
		
	}
}