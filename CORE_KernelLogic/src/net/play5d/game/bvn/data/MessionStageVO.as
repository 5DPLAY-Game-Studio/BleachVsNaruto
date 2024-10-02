package net.play5d.game.bvn.data
{
	import net.play5d.kyo.utils.KyoRandom;

	public class MessionStageVO
	{
		public var fighters:Array;
		public var assister:String;
		public var map:String;
		public var mession:MessionVO;
		
		public var attackRate:Number = 1;
		public var hpRate:Number = 1;
		
		public function getFighters():Array{
			//team
			if(mession.gameMode == 0){
				var a:Array = [];
				a = a.concat(fighters);
				var addlen:int = 3 - a.length;
				if(addlen > 0){
					for(var i:int ; i < addlen ; i++){
						a.push(null);
					}
				}
				return a;
			}else{
				return [KyoRandom.getRandomInArray(fighters)];
			}
		}
		
		public function MessionStageVO()
		{
		}
	}
}