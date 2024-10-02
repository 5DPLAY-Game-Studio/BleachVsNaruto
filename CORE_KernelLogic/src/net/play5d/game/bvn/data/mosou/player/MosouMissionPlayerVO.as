package net.play5d.game.bvn.data.mosou.player
{
	import net.play5d.game.bvn.data.ISaveData;

	public class MosouMissionPlayerVO implements ISaveData
	{
		public var id:String;
//		public var isPassed:Boolean = false;
		public var stars:int = 0;
		
		public function MosouMissionPlayerVO()
		{
		}
		
		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;
//			o.isPassed = isPassed;
			o.stars = stars;
			return o;
		}
		
		public function readSaveObj(o:Object):void
		{
			id = o.id;
//			isPassed = o.isPassed;
			stars = o.stars;
		}
	}
}