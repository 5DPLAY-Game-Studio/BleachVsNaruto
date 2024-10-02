package net.play5d.game.bvn.data.mosou
{

	public class MosouWorldMapVO
	{
		public var id:String;
		public var name:String;
		
		public var areas:Vector.<MosouWorldMapAreaVO>;
		private var _areaMap:Object;
		
		public function MosouWorldMapVO()
		{
		}
		
		public function initWay(way:Array):void{
			areas = new Vector.<MosouWorldMapAreaVO>();
			_areaMap = {};
			
			var i:int, w:Object, mv:MosouWorldMapAreaVO;
			
			for(i = 0; i < way.length; i++){
				w = way[i];
				mv = new MosouWorldMapAreaVO();
				mv.id = w.P;
				
				areas.push(mv);
				_areaMap[mv.id] = mv;
			}
			
			for(i = 0; i < way.length; i++){
				w = way[i];
				mv = _areaMap[w.P];
				
				if(!mv || !w.N) continue;
				
				mv.preOpens = new Vector.<MosouWorldMapAreaVO>();
				
				if(w.N is Array){
					for each(var id:String in w.N){
						if(_areaMap[id]) mv.preOpens.push(_areaMap[id]);
					}
				}else{
					if(_areaMap[w.N]) mv.preOpens.push(_areaMap[w.N]);
				}
				
			}
		}
		
		public function getArea(aid:String):MosouWorldMapAreaVO{
			return _areaMap[aid];
		}
		
	}
}