package net.play5d.game.bvn.data.mosou
{
	public class MosouWorldMapAreaVO
	{
		
		public var id:String;
		public var name:String;
		public var missions:Vector.<MosouMissionVO>;
		
		public var preOpens:Vector.<MosouWorldMapAreaVO>;
		
		// 如果为true，表示当前版本未开放
		public function building():Boolean{
			return !missions || missions.length < 1;
		}
		
		public function MosouWorldMapAreaVO()
		{
		}
		
		public function getMission(id:String):MosouMissionVO{
			for(var i:int; i < missions.length; i++){
				if(missions[i].id == id) return missions[i];
			}
			return null;
		}
		
		public function getNextMission(id:String):MosouMissionVO{
			var m:MosouMissionVO = getMission(id);
			if(!m) return null;
			
			var index:int = missions.indexOf(m);
			if(index == -1) return null;
			
			if(index + 1 > missions.length - 1) return null;
			
			return missions[index + 1];
		}
		
	}
}