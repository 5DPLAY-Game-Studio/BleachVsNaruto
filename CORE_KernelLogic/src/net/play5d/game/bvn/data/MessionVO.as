package net.play5d.game.bvn.data
{
	public class MessionVO
	{
		public var comicType:int;
		public var gameMode:int;
		
		public var stageList:Vector.<MessionStageVO>;
		
		public function MessionVO()
		{
		}
		
		public function initByXML(xml:XML):void{
			comicType = xml.@comicType;
			gameMode = xml.@gameMode;
			
			stageList = new Vector.<MessionStageVO>();
			
			for(var i:int ; i < xml.stage.length() ; i++){
				var msv:MessionStageVO = new MessionStageVO();
				var sx:Object = xml.stage[i];
				var fighter:String = sx.@fighter;
				msv.mession = this;
				msv.assister = sx.@assister;
				msv.fighters = fighter.split(",");
				msv.map = sx.@map;
				msv.hpRate = Number(sx.@hpRate) > 0 ? Number(sx.@hpRate) : 1;
				msv.attackRate = Number(sx.@attackRate) > 0 ? Number(sx.@attackRate) : 1;
				stageList.push(msv);
			}
			
		}
		
	}
}