package net.play5d.game.bvn.data
{
	import flash.geom.Point;

	public class SelectCharListItemVO
	{
		public var x:int;
		public var y:int;
		
		public var fighterID:String;
		
		public var offset:Point;
		
		public var moreFighterIDs:Array;
		
		public function SelectCharListItemVO(x:int,y:int,fighterID:String,offset:Point=null)
		{
			this.x = x;
			this.y = y;
			this.fighterID = fighterID;
			this.offset = offset;
		}
		
		public function getAllFighterIDs():Array{
			var a:Array = [];
			if(fighterID) a.push(fighterID);
			if(moreFighterIDs && moreFighterIDs.length > 0) a = a.concat(moreFighterIDs);
			return a;
		}
	}
}