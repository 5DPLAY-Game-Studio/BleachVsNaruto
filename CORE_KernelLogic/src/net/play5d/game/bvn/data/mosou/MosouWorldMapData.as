package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.data.ISaveData;
	
	public class MosouWorldMapData implements ISaveData
	{
		private var _mapAreaList:Vector.<MosouWorldMapAreaVO>;
		
		public function MosouWorldMapData()
		{
		}
		
		private function initMapAreas():void{
		}
		
		public function toSaveObj():Object
		{
			return null;
		}
		
		public function readSaveObj(o:Object):void
		{
		}
	}
}