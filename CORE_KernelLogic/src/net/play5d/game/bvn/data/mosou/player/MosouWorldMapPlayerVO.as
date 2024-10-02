package net.play5d.game.bvn.data.mosou.player
{
	import net.play5d.game.bvn.data.ISaveData;

	public class MosouWorldMapPlayerVO implements ISaveData
	{
		public var id:String;
//		public var areas:Vector.<MosouWorldMapAreaPlayerVO> = new Vector.<MosouWorldMapAreaPlayerVO>();
		private var _openAreas:Vector.<MosouWorldMapAreaPlayerVO> = new Vector.<MosouWorldMapAreaPlayerVO>();
		
		public function MosouWorldMapPlayerVO()
		{
		}
		
		public function getOpenArea(id:String):MosouWorldMapAreaPlayerVO{
			for(var i:int; i < _openAreas.length; i++){
				if(_openAreas[i].id == id) return _openAreas[i];
			}
			return null;
		}
		
		public function openArea(id:String):void{
			if(!getOpenArea(id)){
				var av:MosouWorldMapAreaPlayerVO = new MosouWorldMapAreaPlayerVO();
				av.id = id;
				_openAreas.push(av);
			}
		}
		
		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;
			
			o.areas = [];
			for(var i:int; i < _openAreas.length; i++){
				var ad:Object = _openAreas[i].toSaveObj();
				o.areas.push(ad);
			}
			
			return o;
		}
		
		public function readSaveObj(o:Object):void
		{
			if(o.id) id = o.id;
			
			if(o.areas){
				_openAreas = new Vector.<MosouWorldMapAreaPlayerVO>();
				for(var i:int; i < o.areas.length; i++){
					var ad:Object = o.areas[i];
					var av:MosouWorldMapAreaPlayerVO = new MosouWorldMapAreaPlayerVO();
					av.readSaveObj(ad);
					_openAreas.push(av);
				}
			}
		}
		
	}
}